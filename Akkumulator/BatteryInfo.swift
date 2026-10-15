import Foundation

nonisolated enum DeviceKind: String, Codable, Sendable {
    case mac, iPhone, iPad, watch, other

    var symbol: String {
        switch self {
        case .mac: "laptopcomputer"
        case .iPhone: "iphone"
        case .iPad: "ipad"
        case .watch: "applewatch"
        case .other: "battery.100percent"
        }
    }
}

/// One snapshot of a device battery, parsed from an IORegistry power-source dictionary.
/// Mac (AppleSmartBattery) and iOS (diagnostics_relay IOPMPowerSource) share the same key names,
/// but macOS 26+ moved most raw values into `BatteryData` and the Pack/Cell child entries.
nonisolated struct BatteryInfo: Sendable, Equatable, Identifiable {
    var id: String
    var name: String
    var model: String
    var productName: String?
    var kind: DeviceKind
    var osVersion: String?
    var connection: String?
    var updated = Date()

    var chargePercent: Int?
    var currentCapacity: Int?
    var fullChargeCapacity: Int?
    var designCapacity: Int?
    var nominalChargeCapacity: Int?
    var cycleCount: Int?
    var designCycleCount: Int?
    var temperature: Double?
    var voltage: Int?
    var amperage: Int?
    var isCharging: Bool?
    var externalConnected: Bool?
    var fullyCharged: Bool?
    var timeRemaining: Int?

    var batterySerial: String?
    var batteryModel: String?
    var manufacturer: String?
    var manufactureDate: Date?
    var operatingHours: Int?
    var firstUse: Date?
    var chemistryID: Int?

    var adapterWatts: Int?
    var adapterName: String?
    var adapterVoltage: Int?
    var adapterCurrent: Int?
    var systemPowerIn: Int?

    var cellVoltages: [Int] = []
    var cellQmax: [Int] = []

    var lifetimeMinTemp: Double?
    var lifetimeMaxTemp: Double?
    var lifetimeMaxChargeCurrent: Int?
    var lifetimeMaxDischargeCurrent: Int?
    var lifetimeMinPackVoltage: Int?
    var lifetimeMaxPackVoltage: Int?

    var raw: [RawEntry] = []

    /// Full charge capacity relative to design capacity.
    var health: Double? {
        guard let full = fullChargeCapacity, let design = designCapacity, design > 0 else { return nil }
        return Double(full) / Double(design)
    }

    /// Signed battery power in watts (negative = discharging).
    var batteryWatts: Double? {
        guard let voltage, let amperage else { return nil }
        return Double(voltage) * Double(amperage) / 1_000_000
    }
}

nonisolated struct RawEntry: Sendable, Equatable, Identifiable {
    var key: String
    var value: String
    var id: String { key }
}

nonisolated extension BatteryInfo {
    /// - Parameters:
    ///   - registry: properties of the power source entry.
    ///   - children: properties of child entries (macOS 26+: AppleSmartBatteryPack / …Bank / …Cell), with "IOClass" set.
    init(id: String, name: String, model: String, kind: DeviceKind, registry: [String: Any], children: [[String: Any]] = []) {
        self.init(id: id, name: name, model: model, kind: kind)

        let packs = children.filter { ($0["IOClass"] as? String)?.hasSuffix("Pack") == true }
        var sources = [registry, registry["BatteryData"] as? [String: Any] ?? [:]]
        for pack in packs { sources += [pack, pack["BatteryData"] as? [String: Any] ?? [:]] }
        let lifetime = sources.compactMap { $0["LifetimeData"] as? [String: Any] }
        let r = Lookup(sources: sources + lifetime)

        fullChargeCapacity = r.int("AppleRawMaxCapacity") ?? r.int("FullChargeCapacity")
        currentCapacity = r.int("AppleRawCurrentCapacity") ?? r.int("RemainingCapacity")
        designCapacity = r.int("DesignCapacity")
        nominalChargeCapacity = r.int("NominalChargeCapacity")
        if r.int("MaxCapacity") == 100, let percent = r.int("CurrentCapacity") {
            chargePercent = percent
        } else if let current = currentCapacity, let full = fullChargeCapacity, full > 0 {
            chargePercent = Int((Double(current) / Double(full) * 100).rounded())
        }
        cycleCount = r.int("CycleCount")
        designCycleCount = r.int("DesignCycleCount9C") ?? r.int("DesignCycleCount70")
        temperature = (r.int("Temperature") ?? r.int("VirtualTemperature")).map { Double($0) / 100 }
        voltage = r.int("Voltage") ?? r.int("AppleRawBatteryVoltage")
        amperage = r.int("InstantAmperage").flatMap { $0 == 0 ? nil : $0 } ?? r.int("Amperage")
        isCharging = r.bool("IsCharging")
        externalConnected = r.bool("ExternalConnected")
        fullyCharged = r.bool("FullyCharged")
        timeRemaining = r.int("TimeRemaining").flatMap { $0 == 65535 ? nil : $0 }

        batterySerial = r.string("Serial")
        batteryModel = r.string("DeviceName")
        manufacturer = r.string("Manufacturer")
        chemistryID = r.int("ChemID")
        operatingHours = r.int("TotalOperatingTime")
        firstUse = r.int("DateOfFirstUse").flatMap { $0 > 0 ? Date(timeIntervalSinceReferenceDate: TimeInterval($0)) : nil }
        manufactureDate = r.int("ManufactureDate").flatMap(Self.smartBatteryDate)
            ?? batterySerial.flatMap { Self.manufactureDate(serial: $0, operatingHours: operatingHours) }

        let adapter = r.dict("AdapterDetails")
        adapterWatts = (adapter["Watts"] as? NSNumber)?.intValue
        adapterName = adapter["Name"] as? String ?? adapter["Description"] as? String
        adapterVoltage = (adapter["AdapterVoltage"] as? NSNumber)?.intValue
        adapterCurrent = (adapter["Current"] as? NSNumber)?.intValue
        systemPowerIn = (r.dict("PowerTelemetryData")["SystemPowerIn"] as? NSNumber)?.intValue

        // Per-cell values sit on the series banks (each bank = parallel cells), not on the …Cell entries.
        let cellData = children.compactMap { $0["BatteryData"] as? [String: Any] }.filter { $0["CellVoltage"] is NSNumber }
        cellVoltages = r.ints("CellVoltage") ?? cellData.compactMap { ($0["CellVoltage"] as? NSNumber)?.intValue }
        cellQmax = r.ints("Qmax") ?? cellData.compactMap { ($0["Qmax"] as? NSNumber)?.intValue }

        // Mac gauges log lifetime temperatures in °C, iOS gauges in 0.1 °C.
        let tempScale = kind == .mac ? 1.0 : 10.0
        lifetimeMinTemp = r.int("MinimumTemperature").map { Double($0) / tempScale }
        lifetimeMaxTemp = r.int("MaximumTemperature").map { Double($0) / tempScale }
        lifetimeMaxChargeCurrent = r.int("MaximumChargeCurrent")
        lifetimeMaxDischargeCurrent = r.int("MaximumDischargeCurrent")
        lifetimeMinPackVoltage = r.int("MinimumPackVoltage")
        lifetimeMaxPackVoltage = r.int("MaximumPackVoltage")

        raw = Self.flatten(registry, prefix: "")
        var counts: [String: Int] = [:]
        for child in children {
            let kind = (child["IOClass"] as? String ?? "Child").replacingOccurrences(of: "AppleSmartBattery", with: "")
            raw += Self.flatten(child, prefix: "\(kind)\(counts[kind, default: 0]).")
            counts[kind, default: 0] += 1
        }
    }

    /// Smart Battery Spec packs the date as (year-1980)<<9 | month<<5 | day. Apple Silicon gauges reuse the key for
    /// an unrelated ASCII code (identical across different iPhones), so anything outside 16 bits is ignored.
    static func smartBatteryDate(_ value: Int) -> Date? {
        guard value > 0, value < 0x10000 else { return nil }
        let comps = DateComponents(year: 1980 + (value >> 9), month: (value >> 5) & 0xF, day: value & 0x1F)
        return Calendar(identifier: .gregorian).date(from: comps)
    }

    /// 17-character Apple battery serials carry the production year's last digit at index 3 and the ISO week at 4–5
    /// (same rule coconutBattery uses). The decade is the latest one that still fits before the battery's operating time began.
    /// Newer 18-character serials (iPhone 15 and later) follow another scheme that coconutBattery does not decode either.
    static func manufactureDate(serial: String, operatingHours: Int?, now: Date = .now) -> Date? {
        let chars = Array(serial)
        guard chars.count == 17, let digit = chars[3].wholeNumberValue,
              let week = Int(String(chars[4...5])), (1...53).contains(week) else { return nil }
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .gmt
        let latest = now.addingTimeInterval(-Double(operatingHours ?? 0) * 3600)
        let thisYear = calendar.component(.year, from: now)
        var year = thisYear - (thisYear - digit) % 10
        while year >= 2000 {
            if let date = calendar.date(from: DateComponents(weekOfYear: week, yearForWeekOfYear: year)), date <= latest { return date }
            year -= 10
        }
        return nil
    }

    static func flatten(_ dict: [String: Any], prefix: String) -> [RawEntry] {
        dict.keys.sorted().flatMap { key -> [RawEntry] in
            let path = prefix + key
            switch dict[key] {
            case let nested as [String: Any]:
                return flatten(nested, prefix: path + ".")
            case let data as Data:
                return [RawEntry(key: path, value: "<" + data.prefix(64).map { String(format: "%02x", $0) }.joined() + (data.count > 64 ? "…" : "") + ">")]
            case let array as [Any]:
                return array.enumerated().flatMap { i, element in flatten(["": element], prefix: "\(path)[\(i)]") }
            case let number as NSNumber where CFGetTypeID(number) == CFBooleanGetTypeID():
                return [RawEntry(key: path, value: number.boolValue ? "Yes" : "No")]
            case let number as NSNumber:
                return [RawEntry(key: path, value: number.description)]
            case let value?:
                return [RawEntry(key: path, value: "\(value)")]
            case nil:
                return []
            }
        }
    }
}

/// First-hit key lookup across several dictionaries.
private nonisolated struct Lookup {
    let sources: [[String: Any]]

    func value(_ key: String) -> Any? { sources.lazy.compactMap { $0[key] }.first }
    // IOKit stores signed currents as SInt64; int64Value keeps the sign either way.
    func int(_ key: String) -> Int? { (value(key) as? NSNumber).map { Int($0.int64Value) } }
    func ints(_ key: String) -> [Int]? { (value(key) as? [NSNumber])?.map { Int($0.int64Value) } }
    func bool(_ key: String) -> Bool? { (value(key) as? NSNumber)?.boolValue }
    func string(_ key: String) -> String? { (value(key) as? String).flatMap { $0.isEmpty ? nil : $0 } }
    func dict(_ key: String) -> [String: Any] { value(key) as? [String: Any] ?? [:] }
}
