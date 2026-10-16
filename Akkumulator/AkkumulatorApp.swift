import Security
import Sparkle
import SwiftData
import SwiftUI

@main
struct AkkumulatorApp: App {
    let container: ModelContainer
    @State private var store: BatteryStore
    private let updater: SPUStandardUpdaterController
    @AppStorage(Defaults.menuBarItem) private var menuBarItem = MenuBarItem.off

    init() {
        Defaults.register()
        updater = SPUStandardUpdaterController(startingUpdater: !Self.isTesting, updaterDelegate: nil, userDriverDelegate: nil)
        container = Self.makeContainer()
        _store = State(initialValue: BatteryStore(context: container.mainContext))
    }

    var body: some Scene {
        Window("Akkumulator", id: "main") {
            ContentView()
                .environment(store)
                .frame(minWidth: 820, minHeight: 560)
        }
        .modelContainer(container)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") { updater.checkForUpdates(nil) }
            }
            CommandGroup(after: .importExport) {
                Button("Import coconutBattery Data…") { store.importCoconutBatteryWithPanel() }
            }
        }

        MenuBarExtra(isInserted: Binding { menuBarItem != .off } set: { if !$0 { menuBarItem = .off } }) {
            MenuBarView()
                .environment(store)
                .modelContainer(container)
        } label: {
            if menuBarItem == .percent, let mac = store.mac {
                Label(mac.chargePercent.map { "\($0) %" } ?? "–", systemImage: mac.batterySymbol)
                    .labelStyle(.titleAndIcon)
            } else {
                Image(systemName: store.mac?.batterySymbol ?? "battery.100percent")
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(store)
        }
    }

    /// iCloud sync needs the CloudKit entitlement, which only a paid team's provisioning profile can grant.
    static let hasCloudKitEntitlement: Bool = {
        guard let task = SecTaskCreateFromSelf(nil),
              let services = SecTaskCopyValueForEntitlement(task, "com.apple.developer.icloud-services" as CFString, nil) as? [String]
        else { return false }
        return services.contains("CloudKit")
    }()

    static let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    static var isSyncing: Bool { hasCloudKitEntitlement && UserDefaults.standard.bool(forKey: Defaults.iCloudSync) }

    private static func makeContainer() -> ModelContainer {
        // Unit tests run inside the app; keep them away from the real (synced) history.
        let memoryOnly = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        if isTesting {
            return try! ModelContainer(for: BatterySample.self, configurations: memoryOnly)
        }
        // Unsandboxed, the default store would be the shared ~/Library/Application Support/default.store.
        let directory = URL.applicationSupportDirectory.appending(path: "Akkumulator")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let configuration = ModelConfiguration(url: directory.appending(path: "History.store"), cloudKitDatabase: isSyncing ? .automatic : .none)
        if let container = try? ModelContainer(for: BatterySample.self, configurations: configuration) { return container }
        // Never lose the app to a broken store or CloudKit setup; history just won't persist this session.
        return try! ModelContainer(for: BatterySample.self, configurations: memoryOnly)
    }
}

struct SettingsView: View {
    @Environment(BatteryStore.self) private var store
    @AppStorage(Defaults.iCloudSync) private var iCloudSync = true
    @AppStorage(Defaults.autoSnapshot) private var autoSnapshot = true
    @AppStorage(Defaults.macAlertThreshold) private var macThreshold = 0
    @AppStorage(Defaults.iosAlertThreshold) private var iosThreshold = 0
    @AppStorage(Defaults.menuBarItem) private var menuBarItem = MenuBarItem.off
    @AppStorage(Defaults.temperatureUnit) private var tempUnit = TemperatureUnit.celsius
    @State private var language = Self.appLanguage
    private static let launchLanguage = appLanguage

    /// The app's own AppleLanguages override; "" follows the system, which falls back to English (development region).
    private static var appLanguage: String {
        (UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "")?["AppleLanguages"] as? [String])?.first ?? ""
    }

    var body: some View {
        Form {
            Section {
                Picker("Menu bar", selection: $menuBarItem) {
                    Text("Off").tag(MenuBarItem.off)
                    Text("Icon").tag(MenuBarItem.icon)
                    Text("Battery percentage").tag(MenuBarItem.percent)
                }
                Picker("Temperature", selection: $tempUnit) {
                    Text("Celsius (°C)").tag(TemperatureUnit.celsius)
                    Text("Fahrenheit (°F)").tag(TemperatureUnit.fahrenheit)
                }
                Picker("Language", selection: $language) {
                    Text("System").tag("")
                    ForEach(Bundle.main.localizations.filter { $0 != "Base" }.sorted(), id: \.self) { code in
                        let locale = Locale(identifier: code)
                        Text(locale.localizedString(forIdentifier: code)?.capitalized(with: locale) ?? code).tag(code)
                    }
                }
                .onChange(of: language) { _, code in
                    if code.isEmpty { UserDefaults.standard.removeObject(forKey: "AppleLanguages") }
                    else { UserDefaults.standard.set([code], forKey: "AppleLanguages") }
                }
                if language != Self.launchLanguage {
                    Text("Takes effect after restarting Akkumulator.").font(.caption).foregroundStyle(.orange)
                }
            }
            Section("History") {
                Toggle("Save a snapshot automatically once a day", isOn: $autoSnapshot)
                LabeledContent("coconutBattery") {
                    Button("Import Data…") { store.importCoconutBatteryWithPanel() }
                }
                Toggle("Sync history via iCloud", isOn: $iCloudSync)
                    .disabled(!AkkumulatorApp.hasCloudKitEntitlement)
                if !AkkumulatorApp.hasCloudKitEntitlement {
                    Text("This build has no iCloud (CloudKit) entitlement. Sign with your team and add the iCloud capability to enable sync.")
                        .font(.caption).foregroundStyle(.secondary)
                } else if iCloudSync != AkkumulatorApp.isSyncing {
                    Text("Takes effect after restarting Akkumulator.").font(.caption).foregroundStyle(.orange)
                }
            }
            Section("Notifications") {
                Picker("Mac battery below", selection: $macThreshold) { thresholdOptions }
                Picker("iPhone/iPad battery below", selection: $iosThreshold) { thresholdOptions }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize()
    }

    @ViewBuilder private var thresholdOptions: some View {
        Text("Off").tag(0)
        ForEach([5, 10, 15, 20, 25, 30, 40, 50], id: \.self) { Text("\($0) %").tag($0) }
    }
}

enum MenuBarItem: String {
    case off, icon, percent
}
