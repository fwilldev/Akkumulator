import Foundation

/// Opaque, retained AMDeviceRef from Apple's private MobileDevice.framework.
nonisolated struct DeviceHandle: @unchecked Sendable, Hashable {
    let pointer: UnsafeMutableRawPointer
}

nonisolated enum DeviceEvent: Sendable {
    case connected(DeviceHandle)
    case disconnected(DeviceHandle)
}

nonisolated enum MobileDeviceError: LocalizedError {
    case unavailable, notPaired, failed(String, Int32)

    var errorDescription: String? {
        switch self {
        case .unavailable: String(localized: "MobileDevice.framework is not available.")
        case .notPaired: String(localized: "Unlock the device and tap “Trust This Computer”.")
        case let .failed(step, code): String(localized: "\(step) failed (\(String(code, radix: 16)))")
        }
    }
}

/// Talks to iPhones/iPads over USB and Wi-Fi via the private MobileDevice.framework (the same route Finder and coconutBattery use).
/// Battery data comes from the lockdown service `com.apple.mobile.diagnostics_relay`, which returns the device's IORegistry power source.
nonisolated enum MobileDevice {
    typealias Ref = UnsafeMutableRawPointer
    typealias Callback = @convention(c) (UnsafeRawPointer?, UnsafeMutableRawPointer?) -> Void

    private struct API {
        let subscribe: @convention(c) (Callback, UInt32, UInt32, UnsafeMutableRawPointer?, UnsafeMutablePointer<UnsafeMutableRawPointer?>, CFDictionary) -> Int32
        let retain: @convention(c) (Ref) -> Ref
        let release: @convention(c) (Ref) -> Void
        let connect, disconnect, isPaired, validatePairing, startSession, stopSession, interfaceType: @convention(c) (Ref) -> Int32
        let copyIdentifier: @convention(c) (Ref) -> Unmanaged<CFString>?
        let copyValue: @convention(c) (Ref, CFString?, CFString) -> Unmanaged<CFTypeRef>?
        let startService: @convention(c) (Ref, CFString, CFDictionary?, UnsafeMutablePointer<UnsafeMutableRawPointer?>) -> Int32
        let send: @convention(c) (UnsafeMutableRawPointer, CFTypeRef, CFIndex) -> Int32
        let receive: @convention(c) (UnsafeMutableRawPointer, UnsafeMutablePointer<Unmanaged<CFTypeRef>?>, UnsafeMutablePointer<CFIndex>?) -> Int32
        let invalidate: @convention(c) (UnsafeMutableRawPointer) -> Int32
    }

    private static let api: API? = {
        guard let lib = dlopen("/Library/Apple/System/Library/PrivateFrameworks/MobileDevice.framework/MobileDevice", RTLD_NOW)
            ?? dlopen("/System/Library/PrivateFrameworks/MobileDevice.framework/MobileDevice", RTLD_NOW) else { return nil }
        struct Missing: Error {}
        func f<T>(_ name: String) throws -> T {
            guard let symbol = dlsym(lib, name) else { throw Missing() }
            return unsafeBitCast(symbol, to: T.self)
        }
        return try? API(subscribe: f("AMDeviceNotificationSubscribeWithOptions"), retain: f("AMDeviceRetain"), release: f("AMDeviceRelease"),
                        connect: f("AMDeviceConnect"), disconnect: f("AMDeviceDisconnect"), isPaired: f("AMDeviceIsPaired"),
                        validatePairing: f("AMDeviceValidatePairing"), startSession: f("AMDeviceStartSession"), stopSession: f("AMDeviceStopSession"),
                        interfaceType: f("AMDeviceGetInterfaceType"), copyIdentifier: f("AMDeviceCopyDeviceIdentifier"), copyValue: f("AMDeviceCopyValue"),
                        startService: f("AMDeviceSecureStartService"), send: f("AMDServiceConnectionSendMessage"),
                        receive: f("AMDServiceConnectionReceiveMessage"), invalidate: f("AMDServiceConnectionInvalidate"))
    }()

    private final class Box: @unchecked Sendable {
        let handler: @Sendable (DeviceEvent) -> Void
        init(_ handler: @escaping @Sendable (DeviceEvent) -> Void) { self.handler = handler }
    }

    /// Subscribes for the app's lifetime. Handles are retained; the handler must call `release` after a disconnect.
    static func subscribe(_ handler: @escaping @Sendable (DeviceEvent) -> Void) throws {
        guard let api else { throw MobileDeviceError.unavailable }
        let context = Unmanaged.passRetained(Box(handler)).toOpaque()
        let callback: Callback = { info, context in
            // Callback info layout: device pointer, then a UInt32 message (1 = connected, 2 = disconnected).
            guard let info, let context, let device = info.load(as: Ref?.self), let api = MobileDevice.api else { return }
            let box = Unmanaged<Box>.fromOpaque(context).takeUnretainedValue()
            switch info.load(fromByteOffset: MemoryLayout<Ref>.size, as: UInt32.self) {
            case 1: box.handler(.connected(DeviceHandle(pointer: api.retain(device))))
            case 2: box.handler(.disconnected(DeviceHandle(pointer: device)))
            default: break
            }
        }
        var notification: UnsafeMutableRawPointer?
        let options = ["NotificationOptionSearchForPairedDevices": true] as CFDictionary
        let status = api.subscribe(callback, 0, 0, context, &notification, options)
        guard status == 0 else { throw MobileDeviceError.failed("Subscribe", status) }
    }

    static func retain(_ device: DeviceHandle) { _ = api?.retain(device.pointer) }
    static func release(_ device: DeviceHandle) { api?.release(device.pointer) }

    static func identifier(_ device: DeviceHandle) -> String? {
        api?.copyIdentifier(device.pointer)?.takeRetainedValue() as String?
    }

    static func isWiFi(_ device: DeviceHandle) -> Bool { api?.interfaceType(device.pointer) == 2 }

    /// Blocking; call off the main thread.
    static func readBattery(_ device: DeviceHandle) throws -> BatteryInfo {
        guard let api else { throw MobileDeviceError.unavailable }
        let dev = device.pointer
        func check(_ step: String, _ status: Int32) throws {
            if status != 0 { throw MobileDeviceError.failed(step, status) }
        }

        try check("Connect", api.connect(dev))
        defer { _ = api.disconnect(dev) }
        guard api.isPaired(dev) != 0 else { throw MobileDeviceError.notPaired }
        try check("Pairing", api.validatePairing(dev))
        try check("Session", api.startSession(dev))

        func value(_ key: String, domain: String? = nil) -> Any? {
            api.copyValue(dev, domain as CFString?, key as CFString)?.takeRetainedValue()
        }
        let name = value("DeviceName") as? String ?? "iOS Device"
        let productType = value("ProductType") as? String ?? "?"
        let deviceClass = value("DeviceClass") as? String
        let version = value("ProductVersion") as? String
        let serial = value("SerialNumber") as? String
        let batteryDomain = value("BatteryCurrentCapacity", domain: "com.apple.mobile.battery") as? Int
        let charging = value("BatteryIsCharging", domain: "com.apple.mobile.battery") as? Bool

        var service: UnsafeMutableRawPointer?
        let serviceStatus = api.startService(dev, "com.apple.mobile.diagnostics_relay" as CFString, nil, &service)
        _ = api.stopSession(dev)

        var registry: [String: Any] = [:]
        var children: [[String: Any]] = []
        if serviceStatus == 0, let service {
            defer {
                _ = api.send(service, ["Request": "Goodbye"] as CFDictionary, CFIndex(CFPropertyListFormat.xmlFormat_v1_0.rawValue))
                _ = api.invalidate(service)
                Unmanaged<AnyObject>.fromOpaque(service).release()
            }
            func query(_ key: String, _ entry: String) -> [String: Any]? {
                guard api.send(service, ["Request": "IORegistry", key: entry] as CFDictionary, CFIndex(CFPropertyListFormat.xmlFormat_v1_0.rawValue)) == 0 else { return nil }
                var reply: Unmanaged<CFTypeRef>?
                guard api.receive(service, &reply, nil) == 0, let response = reply?.takeRetainedValue() as? [String: Any],
                      let found = (response["Diagnostics"] as? [String: Any])?["IORegistry"] as? [String: Any], !found.isEmpty else { return nil }
                return found
            }
            // Older devices don't expose IOPMPowerSource; fall back to the charger/gauge entries.
            registry = query("EntryClass", "IOPMPowerSource") ?? query("EntryName", "AppleARMPMUCharger") ?? query("EntryName", "AppleSmartBattery") ?? [:]
            for childClass in ["AppleSmartBatteryPack", "AppleSmartBatteryBank", "AppleSmartBatteryCell"] {
                if var child = query("EntryClass", childClass) {
                    child["IOClass"] = childClass
                    children.append(child)
                }
            }
        }
        if registry.isEmpty {
            guard let batteryDomain else { throw MobileDeviceError.failed("Diagnostics", serviceStatus) }
            registry = ["CurrentCapacity": batteryDomain, "MaxCapacity": 100, "IsCharging": charging ?? false]
        }

        let (kind, os): (DeviceKind, String) = switch deviceClass {
        case "iPhone": (.iPhone, "iOS")
        case "iPad": (.iPad, "iPadOS")
        case "Watch": (.watch, "watchOS")
        default: (.other, "iOS")
        }
        var info = BatteryInfo(id: serial ?? identifier(device) ?? name, name: name, model: productType, kind: kind, registry: registry, children: children)
        info.osVersion = version.map { "\(os) \($0)" }
        info.connection = switch api.interfaceType(dev) {
        case 1: "USB"
        case 2: "Wi-Fi"
        default: nil
        }
        return info
    }
}
