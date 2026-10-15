import CryptoKit
import Foundation
import SwiftData
import Testing
@testable import Akkumulator

struct BatteryInfoTests {
    /// macOS 26+ layout (trimmed from a MacBookPro18,3): raw values live in BatteryData and Pack/Cell children.
    @Test func parsesModernMacLayout() {
        let registry: [String: Any] = [
            "CurrentCapacity": 80, "MaxCapacity": 100, "CycleCount": 244, "DesignCycleCount9C": 1000,
            "Voltage": 12152, "Amperage": -1520, "InstantAmperage": 0, "IsCharging": false, "ExternalConnected": false,
            "TimeRemaining": 65535, "Serial": "F8Y209XXXXXXXXXXX", "DeviceName": "bq40z651",
            "AdapterDetails": ["Watts": 90, "AdapterVoltage": 20000, "Current": 4500, "Description": "pd charger"],
            "PowerTelemetryData": ["SystemPowerIn": 33561],
            "BatteryData": ["FullChargeCapacity": 4980, "NominalChargeCapacity": 5130, "RemainingCapacity": 3900, "DesignCapacity": 6075],
        ]
        let children: [[String: Any]] = [
            ["IOClass": "AppleSmartBatteryPack", "BatteryData": [
                "AppleRawMaxCapacity": 4980, "AppleRawCurrentCapacity": 3900, "Temperature": 2909, "ChemID": 20882,
                "ManufactureDate": 60688729911347,
                "LifetimeData": ["TotalOperatingTime": 40008, "MaximumTemperature": 46, "MinimumTemperature": 9,
                                 "MaximumDischargeCurrent": Int64(-5945)],
            ] as [String: Any]],
            ["IOClass": "AppleSmartBatteryBank", "BatteryData": ["CellVoltage": 4050, "Qmax": 5676]],
            ["IOClass": "AppleSmartBatteryCell", "CellData": ["CellCurrent": 1663]],
            ["IOClass": "AppleSmartBatteryBank", "BatteryData": ["CellVoltage": 4051, "Qmax": 5674]],
            ["IOClass": "AppleSmartBatteryBank", "BatteryData": ["CellVoltage": 4050, "Qmax": 5663]],
        ]

        let info = BatteryInfo(id: "mac", name: "Mac", model: "MacBookPro18,3", kind: .mac, registry: registry, children: children)

        #expect(info.chargePercent == 80)
        #expect(info.fullChargeCapacity == 4980)
        #expect(info.designCapacity == 6075)
        #expect(info.health! > 0.8197 && info.health! < 0.8198)
        #expect(info.cycleCount == 244)
        #expect(info.designCycleCount == 1000)
        #expect(info.temperature == 29.09)
        #expect(info.amperage == -1520)
        #expect(info.batteryWatts! < -18.4 && info.batteryWatts! > -18.5)
        #expect(info.timeRemaining == nil)
        #expect(info.cellVoltages == [4050, 4051, 4050])
        #expect(info.cellQmax == [5676, 5674, 5663])
        #expect(info.operatingHours == 40008)
        #expect(info.lifetimeMaxDischargeCurrent == -5945)
        #expect(info.lifetimeMaxTemp == 46)
        // Gauge "ManufactureDate" is ignored; the serial yields 2022-W09, before the 40008 h of operating time began.
        #expect(info.manufactureDate == isoWeek(2022, 9))
        #expect(info.adapterWatts == 90)
        #expect(info.adapterName == "pd charger")
        #expect(info.systemPowerIn == 33561)
        #expect(info.raw.contains(RawEntry(key: "Pack0.BatteryData.LifetimeData.MaximumTemperature", value: "46")))
        #expect(info.raw.contains(RawEntry(key: "AdapterDetails.Watts", value: "90")))
        #expect(info.raw.contains(RawEntry(key: "Bank1.BatteryData.Qmax", value: "5674")))
    }

    /// iOS diagnostics_relay / pre-26 macOS layout: everything at top level, cells as arrays.
    @Test func parsesClassicLayout() {
        let registry: [String: Any] = [
            "AppleRawCurrentCapacity": 2000, "AppleRawMaxCapacity": 2500, "DesignCapacity": 3000, "MaxCapacity": 2500,
            "CurrentCapacity": 2000, "CycleCount": 512, "Temperature": 3150, "IsCharging": true,
            "BatteryData": ["CellVoltage": [3900, 3910], "Qmax": [2600, 2610], "ManufactureDate": 0x5A6F, "DateOfFirstUse": 780192000,
                            "LifetimeData": ["MaximumTemperature": 491]] as [String: Any],
            "Cells": [["A": 1], ["A": 2]],
        ]

        let info = BatteryInfo(id: "x", name: "iPhone", model: "iPhone15,2", kind: .iPhone, registry: registry)

        #expect(info.chargePercent == 80)
        #expect(info.health == 2500.0 / 3000.0)
        #expect(info.temperature == 31.5)
        #expect(info.isCharging == true)
        #expect(info.cellVoltages == [3900, 3910])
        #expect(info.cellQmax == [2600, 2610])
        // 0x5A6F = (45 << 9) | (3 << 5) | 15 → 2025-03-15
        #expect(info.manufactureDate == Calendar(identifier: .gregorian).date(from: DateComponents(year: 2025, month: 3, day: 15)))
        #expect(info.lifetimeMaxTemp == 49.1)
        #expect(info.firstUse == Date(timeIntervalSinceReferenceDate: 780192000))
        #expect(info.raw.contains(RawEntry(key: "Cells[1].A", value: "2")))
        #expect(info.raw.contains(RawEntry(key: "BatteryData.CellVoltage[0]", value: "3900")))
    }

    @Test func decodesManufactureDateFromSerial() {
        let now = Date(timeIntervalSince1970: 1_791_244_800) // 2026-10-06
        #expect(BatteryInfo.manufactureDate(serial: "F5D134XXXXXXXXXXX", operatingHours: nil, now: now) == isoWeek(2021, 34))
        #expect(BatteryInfo.manufactureDate(serial: "D86704XXXXXXXXXXX", operatingHours: nil, now: now) == isoWeek(2017, 4))
        // Digit 6 alone would mean 2026-W40, but 2 years of operating time push it back a decade.
        #expect(BatteryInfo.manufactureDate(serial: "F8Y640XXXXXXXXXXX", operatingHours: 2 * 8760, now: now) == isoWeek(2016, 40))
        #expect(BatteryInfo.manufactureDate(serial: "F5DHJLXXXXXXXXXXXX", operatingHours: nil, now: now) == nil)
        #expect(BatteryInfo.manufactureDate(serial: "F8Y2X9XXXXXXXXXXX", operatingHours: nil, now: now) == nil)
    }

    private func isoWeek(_ year: Int, _ week: Int) -> Date? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .gmt
        return calendar.date(from: DateComponents(weekOfYear: week, yearForWeekOfYear: year))
    }

    @Test func liveMacBatteryIsReadable() throws {
        // Skips silently on desktop Macs without a battery.
        guard let info = MacBattery.read() else { return }
        #expect(info.kind == .mac)
        #expect(info.designCapacity ?? 0 > 0)
        #expect(!info.cellVoltages.isEmpty)
        #expect(info.fullChargeCapacity ?? 0 > 0)
        #expect((0...100).contains(info.chargePercent ?? -1))
    }
}

struct CoconutImportTests {
    @Test func readsExportFile() async throws {
        let raw: [String: Any] = [
            "CycleCount": 244, "CurrentCapacity": 80, "MaxCapacity": 100,
            "EntryChildren": ["BatteryData": ["Temperature": 2909, "AppleRawMaxCapacity": 4999] as [String: Any]] as [String: Any],
        ]
        let archive = try NSKeyedArchiver.archivedData(withRootObject: raw, requiringSecureCoding: false)
        let record: [String: Any] = [
            "Device.Serial": "TESTSERIAL1", "Device.Name": "MacBook Pro ", "Device.Model": "MacBookPro18,3", "Data.Type": "Mac",
            "Data.SnapshotDate": 1_791_269_939.5, "Battery.FCC": 5004, "Battery.DC": 6075, "Battery.CycleCount": 244,
            "Battery.Serial": "F8Y209XXXXXXXXXXX",
            "Battery.Raw": try (archive as NSData).compressed(using: .lz4).base64EncodedString(),
        ]
        let json = try JSONSerialization.data(withJSONObject: [record, ["Device.Serial": "broken"]])
        let key = SymmetricKey(size: .bits256)
        let sealed = try AES.GCM.seal((json as NSData).compressed(using: .lzfse) as Data, using: key).combined!
        let binary = Data("\0junk\0\(Data(repeating: 7, count: 32).base64EncodedString())\0".utf8)
            + key.withUnsafeBytes { Data($0) }.base64EncodedString().utf8 + Data([0xFF, 0])
        let keys = CoconutImport.candidateKeys(in: binary)
        #expect(keys.count == 2)

        let entries = try CoconutImport.read(sealed, keys: keys)

        #expect(entries.count == 1)
        let (info, date) = try #require(entries.first)
        #expect(date == Date(timeIntervalSince1970: 1_791_269_939.5))
        #expect(info.id == "TESTSERIAL1")
        #expect(info.name == "MacBook Pro")
        #expect(info.kind == .mac)
        #expect(info.fullChargeCapacity == 5004)
        #expect(info.designCapacity == 6075)
        #expect(info.chargePercent == 80)
        #expect(info.temperature == 29.09)
        #expect(info.batterySerial == "F8Y209XXXXXXXXXXX")
        #expect(throws: CoconutImport.InvalidFile.self) { try CoconutImport.read(Data("nope".utf8), keys: keys) }

        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID()).ccba")
        try sealed.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let container = try ModelContainer(for: BatterySample.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        let store = await BatteryStore(context: container.mainContext)
        #expect(try await store.importCoconutBattery(from: url, keys: keys) == 1)
        #expect(try await store.importCoconutBattery(from: url, keys: keys) == 0)
    }
}
