import AppKit
import CryptoKit
import Foundation
import SwiftData
import UniformTypeIdentifiers

/// Reads coconutBattery 4.x "Export data" files (.ccba): AES-GCM sealed box (key embedded in coconutBattery) → LZFSE → JSON array.
/// Each record's "Battery.Raw" is an LZ4-compressed NSKeyedArchiver dump of the device's IORegistry power source.
nonisolated enum CoconutImport {
    struct InvalidFile: LocalizedError {
        var errorDescription: String? { String(localized: "This is not a coconutBattery export (.ccba) file.") }
    }

    struct NotInstalled: LocalizedError {
        var errorDescription: String? { String(localized: "Importing needs coconutBattery installed on this Mac.") }
    }

    /// The key is read from the installed coconutBattery instead of being shipped here: it is coconutBattery's, not ours.
    static func installedKeys() throws -> [SymmetricKey] {
        guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.coconut-flavour.coconutBattery"),
              let executable = Bundle(url: app)?.executableURL,
              let binary = try? Data(contentsOf: executable)
        else { throw NotInstalled() }
        return candidateKeys(in: binary)
    }

    /// Every Base64-encoded 32-byte string in the binary; AES-GCM authentication picks the right one.
    static func candidateKeys(in binary: Data) -> [SymmetricKey] {
        String(decoding: binary, as: UTF8.self).matches(of: /[A-Za-z0-9+\/]{43}=/)
            .compactMap { Data(base64Encoded: String($0.output)) }
            .filter { $0.count == 32 }
            .map { SymmetricKey(data: $0) }
    }

    static func read(_ data: Data, keys: [SymmetricKey]) throws -> [(info: BatteryInfo, date: Date)] {
        guard let box = try? AES.GCM.SealedBox(combined: data),
              let plain = keys.lazy.compactMap({ try? AES.GCM.open(box, using: $0) }).first,
              let json = try? (plain as NSData).decompressed(using: .lzfse) as Data,
              let records = try? JSONSerialization.jsonObject(with: json) as? [[String: Any]]
        else { throw InvalidFile() }
        return records.compactMap(entry)
    }

    static func entry(_ record: [String: Any]) -> (info: BatteryInfo, date: Date)? {
        guard let serial = record["Device.Serial"] as? String, let timestamp = record["Data.SnapshotDate"] as? Double else { return nil }
        let model = record["Device.Model"] as? String ?? "?"
        let kind: DeviceKind = if record["Data.Type"] as? String == "Mac" { .mac }
            else if model.hasPrefix("iPhone") { .iPhone }
            else if model.hasPrefix("iPad") { .iPad }
            else if model.hasPrefix("Watch") { .watch }
            else { .other }

        var registry: [String: Any] = [:]
        var children: [[String: Any]] = []
        if let raw = (record["Battery.Raw"] as? String).flatMap({ Data(base64Encoded: $0) }),
           let archive = try? (raw as NSData).decompressed(using: .lz4) as Data,
           let dict = try? NSKeyedUnarchiver.unarchivedObject(
               ofClasses: [NSDictionary.self, NSArray.self, NSString.self, NSNumber.self, NSData.self, NSDate.self], from: archive) as? [String: Any] {
            registry = dict
            // coconutBattery stores the pack entry as "EntryChildren" (Mac) or "PackData.Diagnostics.IORegistry" (iOS).
            let iosPack = ((dict["PackData"] as? [String: Any])?["Diagnostics"] as? [String: Any])?["IORegistry"] as? [String: Any]
            for case var pack? in [dict["EntryChildren"] as? [String: Any], iosPack] {
                pack["IOClass"] = "AppleSmartBatteryPack"
                children.append(pack)
            }
        }

        let name = (record["Device.Name"] as? String ?? model).trimmingCharacters(in: .whitespaces)
        var info = BatteryInfo(id: serial, name: name, model: model, kind: kind, registry: registry, children: children)
        info.fullChargeCapacity = record["Battery.FCC"] as? Int ?? info.fullChargeCapacity
        info.designCapacity = record["Battery.DC"] as? Int ?? info.designCapacity
        info.cycleCount = record["Battery.CycleCount"] as? Int ?? info.cycleCount
        info.batterySerial = record["Battery.Serial"] as? String ?? info.batterySerial
        info.osVersion = record["Device.OSVersion"] as? String
        return (info, Date(timeIntervalSince1970: timestamp))
    }
}

extension BatteryStore {
    /// Imports a coconutBattery export, skipping entries already in the history. Returns the number of new entries.
    @discardableResult
    func importCoconutBattery(from url: URL, keys: [SymmetricKey]? = nil) throws -> Int {
        let entries = try CoconutImport.read(Data(contentsOf: url), keys: keys ?? CoconutImport.installedKeys())
        func key(_ id: String, _ date: Date) -> String { "\(id)|\(Int(date.timeIntervalSince1970))" }
        var existing = Set(((try? context.fetch(FetchDescriptor<BatterySample>())) ?? []).map { key($0.deviceID, $0.date) })
        var added = 0
        for (info, date) in entries where existing.insert(key(info.id, date)).inserted {
            context.insert(BatterySample(info, date: date))
            added += 1
        }
        try context.save()
        return added
    }

    func importCoconutBatteryWithPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "ccba") ?? .data]
        panel.message = String(localized: "Choose a file exported from coconutBattery (File › Export Data).")
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let added = try importCoconutBattery(from: url)
            let alert = NSAlert()
            alert.messageText = String(localized: "Imported \(added) history entries.")
            alert.runModal()
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
