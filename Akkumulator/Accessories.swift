import Foundation
import IOKit.ps

/// A Bluetooth accessory's charge as macOS reports it. Accessories only report a percentage, no capacity or health.
nonisolated struct Accessory: Sendable, Equatable, Identifiable {
    struct Part: Sendable, Equatable {
        var kind: String?
        var percent: Int
        var charging: Bool
    }

    var id: String
    var name: String
    var category: String
    var isApple: Bool
    var parts: [Part]

    var isCharging: Bool { parts.contains(where: \.charging) }

    /// Single-part accessories show their percentage in the row's trailing slot instead.
    var partsText: String {
        guard parts.count > 1 else { return "" }
        return parts.map { part in
            let label = switch part.kind {
            case "Left": String(localized: "Left")
            case "Right": String(localized: "Right")
            case "Case": String(localized: "Case")
            default: part.kind ?? ""
            }
            return "\(label) \(part.percent) %"
        }.joined(separator: " · ")
    }

    var symbol: String {
        switch category {
        case "Headset", "Headphones": isApple ? "airpods" : "headphones"
        case "Keyboard": "keyboard"
        case "Mouse": "computermouse"
        case "Trackpad": "rectangle.and.hand.point.up.left"
        case "Game Controller": "gamecontroller"
        default: "battery.100percent"
        }
    }
}

nonisolated enum Accessories {
    // Undocumented, but what `pmset -g accps` uses; the public IOPSCopyPowerSourcesInfo only lists the internal battery.
    @_silgen_name("IOPSCopyPowerSourcesByType")
    private static func copyPowerSources(_ type: Int32) -> Unmanaged<CFTypeRef>?

    static func read() -> [Accessory] {
        guard let blob = copyPowerSources(0)?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef]
        else { return [] }
        return parse(list.compactMap { IOPSGetPowerSourceDescription(blob, $0)?.takeUnretainedValue() as? [String: Any] })
    }

    /// AirPods come as two sources sharing a group ID: the buds (with left/right in "Combined Parts") and the case.
    static func parse(_ sources: [[String: Any]]) -> [Accessory] {
        var result: [Accessory] = []
        for source in sources where source["Type"] as? String == "Accessory Source" {
            let group = source["Group Identifier"] as? String ?? source["Accessory Identifier"] as? String
                ?? (source["Power Source ID"] as? NSNumber)?.stringValue ?? UUID().uuidString
            let parts = (source["Combined Parts"] as? [[String: Any]] ?? [source]).compactMap(part)
            let isCase = source["Part Identifier"] as? String == "Case"
            if let i = result.firstIndex(where: { $0.id == group }) {
                if isCase {
                    result[i].parts += parts
                } else {
                    result[i].parts.insert(contentsOf: parts, at: 0)
                    result[i].name = source["Name"] as? String ?? result[i].name
                    result[i].category = source["Accessory Category"] as? String ?? result[i].category
                }
            } else {
                result.append(Accessory(id: group, name: source["Name"] as? String ?? "", category: source["Accessory Category"] as? String ?? "",
                                        isApple: (source["Vendor ID"] as? NSNumber)?.intValue == 76, parts: parts))
            }
        }
        return result.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private static func part(_ dict: [String: Any]) -> Accessory.Part? {
        guard let percent = (dict["Current Capacity"] as? NSNumber)?.intValue else { return nil }
        return Accessory.Part(kind: dict["Part Identifier"] as? String, percent: percent, charging: (dict["Is Charging"] as? NSNumber)?.boolValue == true)
    }
}
