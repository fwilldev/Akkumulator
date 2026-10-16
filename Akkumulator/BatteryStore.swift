import Foundation
import Observation
import SwiftData
import UserNotifications

/// One history entry. All properties are optional or defaulted so CloudKit mirroring accepts the schema.
@Model final class BatterySample {
    var deviceID: String = ""
    var deviceName: String = ""
    var model: String = ""
    var kind: String = DeviceKind.mac.rawValue
    var date: Date = Date.now
    var chargePercent: Int?
    var fullChargeCapacity: Int?
    var designCapacity: Int?
    var cycleCount: Int?
    var temperature: Double?
    var voltage: Int?
    var batterySerial: String?

    init(_ info: BatteryInfo, date: Date = .now) {
        deviceID = info.id
        deviceName = info.name
        model = info.model
        kind = info.kind.rawValue
        self.date = date
        chargePercent = info.chargePercent
        fullChargeCapacity = info.fullChargeCapacity
        designCapacity = info.designCapacity
        cycleCount = info.cycleCount
        temperature = info.temperature
        voltage = info.voltage
        batterySerial = info.batterySerial
    }

    var health: Double? {
        guard let full = fullChargeCapacity, let design = designCapacity, design > 0 else { return nil }
        return Double(full) / Double(design)
    }

    var deviceKind: DeviceKind { DeviceKind(rawValue: kind) ?? .other }
}

enum Defaults {
    static let iCloudSync = "iCloudSync"
    static let autoSnapshot = "autoSnapshot"
    static let macAlertThreshold = "macAlertThreshold"
    static let iosAlertThreshold = "iosAlertThreshold"
    static let menuBarItem = "menuBarItem"
    static let temperatureUnit = "temperatureUnit"

    static func register() {
        UserDefaults.standard.register(defaults: [iCloudSync: true, autoSnapshot: true, macAlertThreshold: 0, iosAlertThreshold: 0,
                                                  temperatureUnit: (Locale.current.measurementSystem == .us ? TemperatureUnit.fahrenheit : .celsius).rawValue])
    }
}

@Observable final class BatteryStore {
    var mac: BatteryInfo?
    var devices: [String: BatteryInfo] = [:]
    var accessories: [Accessory] = []
    /// Connected devices that couldn't be read yet (e.g. not trusted), keyed by UDID.
    var deviceErrors: [String: String] = [:]
    var mobileDeviceError: String?

    @ObservationIgnored let context: ModelContext
    @ObservationIgnored private var handles: [String: [DeviceHandle]] = [:]
    @ObservationIgnored private var reading: Set<String> = []
    @ObservationIgnored private var lastSnapshot: [String: Date] = [:]
    @ObservationIgnored private var alerted: Set<String> = []

    init(context: ModelContext) {
        self.context = context
        refreshMac()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in Task { @MainActor in self.refreshMac() } }
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in Task { @MainActor in self.handles.keys.forEach(self.refreshDevice) } }
        do {
            try MobileDevice.subscribe { event in Task { @MainActor in self.handle(event) } }
        } catch {
            mobileDeviceError = error.localizedDescription
        }
    }

    var allLive: [BatteryInfo] {
        [mac].compactMap(\.self) + devices.values.sorted { $0.name < $1.name }
    }

    /// `devices` is keyed by UDID, but BatteryInfo.id is the serial number.
    func live(_ id: String) -> BatteryInfo? { mac?.id == id ? mac : devices.values.first { $0.id == id } }

    func refreshMac() {
        let accessories = Accessories.read()
        if accessories != self.accessories { self.accessories = accessories }
        guard let info = MacBattery.read() else { return }
        mac = info
        didRead(info)
    }

    func refreshDevice(_ id: String) {
        guard let handle = handles[id]?.first, !reading.contains(id) else { return }
        reading.insert(id)
        MobileDevice.retain(handle)
        Task {
            let result = await Task.detached {
                defer { MobileDevice.release(handle) }
                return Result { try MobileDevice.readBattery(handle) }
            }.value
            reading.remove(id)
            guard handles[id] != nil else { return }
            switch result {
            case .success(let info):
                devices[id] = info
                deviceErrors[id] = nil
                didRead(info)
            case .failure(let error):
                deviceErrors[id] = error.localizedDescription
            }
        }
    }

    /// Saves a history entry now.
    func snapshot(_ info: BatteryInfo) {
        context.insert(BatterySample(info))
        try? context.save()
        lastSnapshot[info.id] = .now
    }

    private func handle(_ event: DeviceEvent) {
        switch event {
        case .connected(let handle):
            guard let id = MobileDevice.identifier(handle) else { return MobileDevice.release(handle) }
            handles[id, default: []].append(handle)
            handles[id]?.sort { !MobileDevice.isWiFi($0) && MobileDevice.isWiFi($1) }
            refreshDevice(id)
        case .disconnected(let handle):
            guard let id = handles.first(where: { $0.value.contains(handle) })?.key else { return }
            handles[id]?.removeAll { $0 == handle }
            MobileDevice.release(handle)
            if handles[id]?.isEmpty == true {
                handles[id] = nil
                devices[id] = nil
                deviceErrors[id] = nil
            }
        }
    }

    private func didRead(_ info: BatteryInfo) {
        autoSnapshot(info)
        checkAlert(info)
    }

    private func autoSnapshot(_ info: BatteryInfo) {
        guard UserDefaults.standard.bool(forKey: Defaults.autoSnapshot), info.fullChargeCapacity != nil else { return }
        if lastSnapshot[info.id] == nil {
            let id = info.id
            var latest = FetchDescriptor<BatterySample>(predicate: #Predicate { $0.deviceID == id }, sortBy: [SortDescriptor(\.date, order: .reverse)])
            latest.fetchLimit = 1
            lastSnapshot[id] = (try? context.fetch(latest))?.first?.date ?? .distantPast
        }
        if let last = lastSnapshot[info.id], Date.now.timeIntervalSince(last) > 24 * 3600 {
            snapshot(info)
        }
    }

    private func checkAlert(_ info: BatteryInfo) {
        let threshold = UserDefaults.standard.integer(forKey: info.kind == .mac ? Defaults.macAlertThreshold : Defaults.iosAlertThreshold)
        guard threshold > 0, let percent = info.chargePercent else { return }
        if percent > threshold || info.isCharging == true {
            alerted.remove(info.id)
        } else if !alerted.contains(info.id) {
            alerted.insert(info.id)
            let content = UNMutableNotificationContent()
            content.title = String(localized: "\(info.name): \(percent) %")
            content.body = String(localized: "Battery is below \(threshold) %.")
            content.sound = .default
            Task {
                let center = UNUserNotificationCenter.current()
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
                try? await center.add(UNNotificationRequest(identifier: "low-\(info.id)", content: content, trigger: nil))
            }
        }
    }
}
