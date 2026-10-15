import Foundation
import IOKit

nonisolated enum MacBattery {
    /// Reads the internal battery, or nil on Macs without one.
    static func read() -> BatteryInfo? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        guard let registry = properties(of: service) else { return nil }

        var children: [[String: Any]] = []
        var iterator: io_iterator_t = 0
        if IORegistryEntryCreateIterator(service, kIOServicePlane, IOOptionBits(kIORegistryIterateRecursively), &iterator) == KERN_SUCCESS {
            defer { IOObjectRelease(iterator) }
            while case let child = IOIteratorNext(iterator), child != 0 {
                defer { IOObjectRelease(child) }
                if var props = properties(of: child) {
                    props["IOClass"] = IOObjectCopyClass(child)?.takeRetainedValue() as String?
                    children.append(props)
                }
            }
        }

        var info = BatteryInfo(id: platform.serial, name: Host.current().localizedName ?? "Mac", model: platform.model,
                               kind: .mac, registry: registry, children: children)
        let os = ProcessInfo.processInfo.operatingSystemVersion
        info.osVersion = "macOS \(os.majorVersion).\(os.minorVersion)" + (os.patchVersion > 0 ? ".\(os.patchVersion)" : "")
        info.productName = platform.productName
        return info
    }

    private static func properties(of entry: io_registry_entry_t) -> [String: Any]? {
        var props: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(entry, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return nil }
        return props?.takeRetainedValue() as? [String: Any]
    }

    // The serial number is the device ID so coconutBattery imports and other Macs' synced history line up.
    private static let platform: (serial: String, model: String, productName: String?) = {
        let expert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        defer { IOObjectRelease(expert) }
        let product = IORegistryEntryFromPath(kIOMainPortDefault, "IODeviceTree:/product")
        defer { IOObjectRelease(product) }
        return (
            serial: property(expert, "IOPlatformSerialNumber") as? String ?? property(expert, "IOPlatformUUID") as? String ?? "this-mac",
            model: cString(property(expert, "model")) ?? "Mac",
            productName: cString(property(product, "product-name"))
        )
    }()

    private static func property(_ entry: io_registry_entry_t, _ key: String) -> Any? {
        entry == 0 ? nil : IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
    }

    private static func cString(_ value: Any?) -> String? {
        (value as? Data).map { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
    }
}
