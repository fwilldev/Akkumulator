# Akkumulator – Plan

coconutBattery-Alternative für macOS (nur Apple Silicon).

## Technologie-Entscheidung

Swift 6 + SwiftUI, macOS 15+, arm64 only. Begründung:
- Mac-Akku: IOKit (`AppleSmartBattery` + Pack/Cell-Kinder) – direkt aus Swift lesbar.
- iPhone/iPad: privates `MobileDevice.framework` (per `dlopen`), Dienst `com.apple.mobile.diagnostics_relay` → IORegistry `IOPMPowerSource`. Gleicher Weg wie coconutBattery, USB + WLAN.
- History: SwiftData; iCloud-Sync über SwiftData-CloudKit-Spiegelung (kein eigener Sync-Code).
- Charts: Swift Charts. Menüleiste: `MenuBarExtra`. Benachrichtigungen: UserNotifications.
- Kein App-Sandbox (MobileDevice ist privat) → Vertrieb per Developer ID, nicht App Store.

## Tasks

- [x] T1 Projekt-Setup: Xcode-Projekt (synchronisierte Ordner), arm64, macOS 15, Swift 6, kein Sandbox, Test-Target
- [x] T2 `BatteryInfo` + Parser für Mac- und iOS-IORegistry-Dicts (robust über macOS 14–27-Layouts), Tests
- [x] T3 Mac-Reader (IOKit, Live-Refresh)
- [x] T4 iOS/iPadOS-Reader (MobileDevice, Connect/Disconnect, USB + WLAN)
- [x] T5 History: SwiftData-Modell, Auto-Snapshot max. 1×/Tag/Gerät, manueller Snapshot, Löschen
- [x] T6 iCloud-Sync: CloudKit-Spiegelung, Schalter in Einstellungen, Erkennung fehlendes Entitlement
- [x] T7 Hauptfenster: Geräteliste, Übersicht (Ladung, Gesundheit, Zyklen, Temperatur, Leistung), Detailtabellen inkl. Zellen, Rohdaten
- [x] T8 History-UI: Chart (Kapazität/Zyklen über Zeit), sortierbare Tabelle, CSV-Export
- [x] T9 Menüleiste mit Mac- und iOS-Werten
- [x] T10 Benachrichtigungen bei Unterschreiten von Schwellwerten (Mac / iOS)
- [x] T11 Build + Tests verifizieren, README
- [x] T12 coconutBattery-Import (.ccba), Geräte-ID = Seriennummer
- [x] T13 Herstellungsdatum aus Akku-Seriennummer (Reverse Engineering coconutBattery 4.4)

## Bewusst weggelassen
- SSD-Infos, HTML-Druckvorlagen, „coconutBattery Online" – nicht akkubezogen bzw. eigener Server nötig.
- Intel-Macs.
