import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(BatteryStore.self) private var store
    @Query(sort: \BatterySample.date, order: .reverse) private var samples: [BatterySample]
    @State private var selection: String?
    @State private var showSupportPrompt = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Connected") {
                    ForEach(store.allLive) { info in
                        DeviceRow(name: info.name, subtitle: info.productName ?? info.model, symbol: info.kind.symbol, percent: info.chargePercent,
                                  charging: info.isCharging == true)
                            .tag(info.id)
                    }
                    ForEach(store.deviceErrors.keys.filter { store.devices[$0] == nil }.sorted(), id: \.self) { id in
                        DeviceRow(name: String(localized: "iOS Device"), subtitle: store.deviceErrors[id] ?? "", symbol: "exclamationmark.triangle", percent: nil)
                            .selectionDisabled()
                    }
                    if let error = store.mobileDeviceError {
                        Text(error).font(.caption).foregroundStyle(.secondary)
                    }
                }
                if !store.accessories.isEmpty {
                    Section("Accessories") {
                        ForEach(store.accessories) { accessory in
                            DeviceRow(name: accessory.name, subtitle: accessory.partsText, symbol: accessory.symbol,
                                      percent: accessory.parts.count == 1 ? accessory.parts[0].percent : nil, charging: accessory.isCharging)
                                .selectionDisabled()
                        }
                    }
                }
                let offline = historyDevices.filter { store.live($0.deviceID) == nil }
                if !offline.isEmpty {
                    Section("History") {
                        ForEach(offline) { sample in
                            DeviceRow(name: sample.deviceName, subtitle: sample.model, symbol: sample.deviceKind.symbol, percent: nil)
                                .tag(sample.deviceID)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 240)
            .safeAreaInset(edge: .bottom, alignment: .leading) {
                Link(destination: SupportPrompt.url) {
                    Label("Support the Developer", systemImage: "cup.and.saucer.fill")
                }
                .font(.callout)
                .padding(12)
            }
        } detail: {
            if let id = selection ?? store.mac?.id {
                DeviceDetail(id: id, fallbackName: samples.first { $0.deviceID == id }?.deviceName ?? "")
                    .id(id)
            } else {
                ContentUnavailableView("No Battery", systemImage: "battery.0percent",
                                       description: Text("Connect an iPhone or iPad via USB or Wi-Fi."))
            }
        }
        .task { showSupportPrompt = SupportPrompt.isDue }
        .alert("Enjoying Akkumulator?", isPresented: $showSupportPrompt) {
            Button("Support on Ko-fi") {
                SupportPrompt.done()
                openURL(SupportPrompt.url)
            }
            Button("Later") { SupportPrompt.later() }
            Button("No Thanks", role: .cancel) { SupportPrompt.done() }
        } message: {
            Text("If so, I'd appreciate your support: ko-fi.com/fwilldev")
        }
    }

    /// Latest sample per device, which also covers devices synced from other Macs.
    private var historyDevices: [BatterySample] {
        var seen = Set<String>()
        return samples.filter { seen.insert($0.deviceID).inserted }
    }
}

/// Asks once for support, a week after the first launch; "Later" asks again after 30 days.
enum SupportPrompt {
    static let url = URL(string: "https://ko-fi.com/fwilldev")!
    private static let key = "supportPromptDate"

    static var isDue: Bool {
        guard let date = UserDefaults.standard.object(forKey: key) as? Date else {
            UserDefaults.standard.set(Date.now.addingTimeInterval(7 * 86400), forKey: key)
            return false
        }
        return date <= .now
    }

    static func later() { UserDefaults.standard.set(Date.now.addingTimeInterval(30 * 86400), forKey: key) }
    static func done() { UserDefaults.standard.set(Date.distantFuture, forKey: key) }
}

private struct DeviceRow: View {
    let name: String
    let subtitle: String
    let symbol: String
    let percent: Int?
    var charging = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Selected rows get a prominent (accent) background where green would be hard to read.
    @Environment(\.backgroundProminence) private var prominence

    private var chargeStyle: AnyShapeStyle { prominence == .increased ? AnyShapeStyle(.primary) : AnyShapeStyle(.green) }

    var body: some View {
        Label {
            HStack(spacing: 4) {
                VStack(alignment: .leading) {
                    Text(name).lineLimit(1)
                    if !subtitle.isEmpty {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    }
                }
                Spacer()
                if charging {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(chargeStyle)
                        .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityLabel("Charging")
                }
                if let percent {
                    Text("\(percent) %")
                        .monospacedDigit()
                        .foregroundStyle(charging ? chargeStyle : AnyShapeStyle(.secondary))
                        .liveValue(percent)
                }
            }
            .animation(reduceMotion ? nil : .bouncy, value: charging)
        } icon: {
            Image(systemName: symbol)
        }
    }
}

private struct DeviceDetail: View {
    enum Tab: String, CaseIterable { case overview = "Overview", details = "Details", history = "History", raw = "Raw Data" }

    let id: String
    let fallbackName: String
    @Environment(BatteryStore.self) private var store
    @State private var tab = Tab.overview
    @State private var opened: Set<Tab> = []
    @State private var justSaved = false

    var body: some View {
        let info = store.live(id)
        Group {
            if let info {
                // Building a tab's Form/Table costs ~200 ms, so visited tabs stay alive and are only hidden.
                ZStack {
                    ForEach(Tab.allCases.filter { $0 == tab || opened.contains($0) }, id: \.self) { page in
                        TabPage(tab: page, info: info, deviceID: id, active: page == tab)
                            .equatable()
                            .opacity(page == tab ? 1 : 0)
                            .allowsHitTesting(page == tab)
                            .accessibilityHidden(page != tab)
                    }
                }
                .onChange(of: tab, initial: true) { _, new in
                    // Overview is cheap to rebuild and runs a charging animation, so it isn't kept.
                    if new != .overview { opened.insert(new) }
                }
            } else {
                HistoryView(deviceID: id)
            }
        }
        .navigationTitle(info?.name ?? fallbackName)
        .toolbar {
            if let info {
                ToolbarItem(placement: .principal) {
                    Picker("View", selection: $tab) {
                        ForEach(Tab.allCases, id: \.self) { Text(LocalizedStringKey($0.rawValue)) }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem {
                    Button {
                        store.snapshot(info)
                        withAnimation { justSaved = true }
                    } label: {
                        Label("Save Snapshot", systemImage: justSaved ? "checkmark" : "square.and.arrow.down")
                    }
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: justSaved)
                    .help("Save the current values to the history")
                    .task(id: justSaved) {
                        guard justSaved, (try? await Task.sleep(for: .seconds(1.5))) != nil else { return }
                        withAnimation { justSaved = false }
                    }
                }
            }
        }
    }
}

/// Hidden pages compare equal regardless of new readings, so live refreshes only update the visible one.
private struct TabPage: View, Equatable {
    let tab: DeviceDetail.Tab
    let info: BatteryInfo
    let deviceID: String
    let active: Bool

    static func == (a: Self, b: Self) -> Bool {
        a.tab == b.tab && a.active == b.active && (!a.active || a.info == b.info)
    }

    var body: some View {
        switch tab {
        case .overview: OverviewView(info: info)
        case .details: DetailsView(info: info)
        case .history: HistoryView(deviceID: deviceID)
        case .raw: RawView(entries: info.raw)
        }
    }
}

private struct OverviewView: View {
    let info: BatteryInfo
    @AppStorage(Defaults.temperatureUnit) private var tempUnit = TemperatureUnit.celsius
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: info.kind.symbol).font(.system(size: 44)).frame(width: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(info.name).font(.title2.bold())
                        Text([info.productName, info.model].compactMap(\.self).joined(separator: " · "))
                        Text([info.osVersion, info.connection].compactMap(\.self).joined(separator: " · "))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(info.statusText, systemImage: info.batterySymbol)
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.pulse, options: .repeating, isActive: info.isCharging == true)
                        .symbolEffectsRemoved(reduceMotion)
                        .font(.callout)
                        .foregroundStyle(info.isCharging == true ? .green : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.quaternary.opacity(0.6), in: .capsule)
                        .animation(.smooth, value: info.statusText)
                }

                HStack(spacing: 40) {
                    Ring(value: info.chargePercent.map { Double($0) / 100 }, title: "Charge",
                         detail: "\(format(info.currentCapacity, "mAh")) / \(format(info.fullChargeCapacity, "mAh"))",
                         color: info.isCharging == true ? .green : .accentColor, charging: info.isCharging == true)
                    Ring(value: info.health, title: "Health",
                         detail: "\(format(info.fullChargeCapacity, "mAh")) / \(format(info.designCapacity, "mAh"))",
                         color: healthColor(info.health))
                }
                .frame(maxWidth: .infinity)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
                    Tile(title: "Cycle Count", symbol: "arrow.triangle.2.circlepath", value: format(info.cycleCount, ""),
                         detail: info.designCycleCount.map { String(localized: "of \($0) designed") })
                    Tile(title: "Temperature", symbol: "thermometer.medium", value: format(info.temperature, tempUnit))
                    Tile(title: "Power", symbol: "bolt.fill", value: format(watts: info.batteryWatts), detail: info.statusText)
                    Tile(title: "Voltage", symbol: "bolt.horizontal.fill", value: info.voltage.map { (Double($0) / 1000).formatted(.number.precision(.fractionLength(2))) + " V" } ?? "–")
                    if let adapter = info.adapterWatts {
                        Tile(title: "Power Adapter", symbol: "powerplug.fill", value: "\(adapter) W", detail: info.adapterName)
                    }
                    if let input = info.systemPowerIn, input > 0 {
                        Tile(title: "System Power Input", symbol: "gauge.with.dots.needle.50percent", value: format(watts: Double(input) / 1000))
                    }
                    if let hours = info.operatingHours {
                        Tile(title: "Operating Time", symbol: "clock", value: formatHours(hours))
                    }
                    if let minutes = info.timeRemaining, minutes > 0 {
                        Tile(title: info.isCharging == true ? "Time to Full" : "Time Remaining", symbol: "hourglass", value: formatHours(minutes / 60, minutes: minutes % 60))
                    }
                }
            }
            .padding(24)
        }
    }
}

private struct DetailsView: View {
    let info: BatteryInfo
    @AppStorage(Defaults.temperatureUnit) private var tempUnit = TemperatureUnit.celsius

    var body: some View {
        Form {
            Section("Capacity") {
                row("Charge", info.chargePercent.map { "\($0) %" })
                row("Remaining capacity", format(info.currentCapacity, "mAh"))
                row("Full charge capacity", format(info.fullChargeCapacity, "mAh"))
                row("Nominal charge capacity", format(info.nominalChargeCapacity, "mAh"))
                row("Design capacity", format(info.designCapacity, "mAh"))
                row("Health", info.health.map { $0.formatted(.percent.precision(.fractionLength(1))) })
            }
            Section("Status") {
                row("Status", info.statusText)
                row("External power", yesNo(info.externalConnected))
                row("Fully charged", yesNo(info.fullyCharged))
                row("Voltage", format(info.voltage, "mV"))
                row("Current", format(info.amperage, "mA"))
                row("Battery power", format(watts: info.batteryWatts))
                row("System power input", info.systemPowerIn.map { format(watts: Double($0) / 1000) })
                row("Temperature", format(info.temperature, tempUnit))
            }
            if !info.cellVoltages.isEmpty {
                Section("Cells") {
                    ForEach(info.cellVoltages.indices, id: \.self) { i in
                        row("Cell \(i + 1)", [(Double(info.cellVoltages[i]) / 1000).formatted(.number.precision(.fractionLength(3))) + " V" as String?,
                                              info.cellQmax.indices.contains(i) ? "Qmax \(info.cellQmax[i]) mAh" : nil]
                                .compactMap(\.self).joined(separator: " · "))
                    }
                    if let min = info.cellVoltages.min(), let max = info.cellVoltages.max(), info.cellVoltages.count > 1 {
                        row("Cell imbalance", "\(max - min) mV")
                    }
                }
            }
            Section("Lifetime") {
                row("Cycle count", info.cycleCount.map { c in info.designCycleCount.map { "\(c) / \($0)" } ?? "\(c)" })
                row("Operating time", info.operatingHours.map { formatHours($0) })
                row("First use", info.firstUse?.formatted(date: .long, time: .omitted))
                row("Min. temperature", format(info.lifetimeMinTemp, tempUnit))
                row("Max. temperature", format(info.lifetimeMaxTemp, tempUnit))
                row("Max. charge current", format(info.lifetimeMaxChargeCurrent, "mA"))
                row("Max. discharge current", format(info.lifetimeMaxDischargeCurrent.map(abs), "mA"))
                row("Min. / max. pack voltage", pair(info.lifetimeMinPackVoltage, info.lifetimeMaxPackVoltage, "mV"))
            }
            if info.adapterWatts != nil || info.adapterName != nil {
                Section("Power Adapter") {
                    row("Name", info.adapterName)
                    row("Power", format(info.adapterWatts, "W"))
                    row("Voltage", format(info.adapterVoltage, "mV"))
                    row("Max. current", format(info.adapterCurrent, "mA"))
                }
            }
            Section("Battery") {
                row("Serial number", info.batterySerial)
                row("Gauge / model", info.batteryModel)
                row("Manufacturer", info.manufacturer)
                row("Manufacture date", info.manufactureDate?.formatted(date: .long, time: .omitted))
                row("Chemistry ID", info.chemistryID.map(String.init))
            }
            Section("Device") {
                row("Name", info.name)
                row("Model", [info.productName, info.model].compactMap(\.self).joined(separator: " · "))
                row("System", info.osVersion)
                row("Connection", info.connection)
                row("Identifier", info.id)
            }
        }
        .formStyle(.grouped)
        .textSelection(.enabled)
    }

    @ViewBuilder private func row(_ title: LocalizedStringKey, _ value: String?) -> some View {
        if let value, !value.isEmpty, value != "–" {
            LabeledContent(title, value: value)
        }
    }

    private func yesNo(_ value: Bool?) -> String? { value.map { $0 ? String(localized: "Yes") : String(localized: "No") } }
    private func pair(_ a: Int?, _ b: Int?, _ unit: String) -> String? {
        guard let a, let b else { return nil }
        return "\(a) / \(b) \(unit)"
    }
}

// textSelection on Table cells makes every cell a text view, which lags with hundreds of rows; copy via row selection instead.
private struct RawView: View {
    let entries: [RawEntry]
    @State private var search = ""
    @State private var selection = Set<RawEntry.ID>()

    var body: some View {
        Table(entries.filter { search.isEmpty || $0.key.localizedCaseInsensitiveContains(search) || $0.value.localizedCaseInsensitiveContains(search) },
              selection: $selection) {
            TableColumn("Key", value: \.key)
            TableColumn("Value", value: \.value)
        }
        // An in-content field instead of .searchable: adding/removing a toolbar search item rebuilds the whole toolbar on every tab switch.
        .safeAreaInset(edge: .top, spacing: 0) {
            TextField("Search", text: $search, prompt: Text("Search"))
                .textFieldStyle(.roundedBorder)
                .padding(8)
        }
        .contextMenu(forSelectionType: RawEntry.ID.self) { ids in
            Button("Copy") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text(ids), forType: .string)
            }
        }
        .onCopyCommand { [NSItemProvider(object: text(selection) as NSString)] }
    }

    private func text(_ ids: Set<RawEntry.ID>) -> String {
        entries.filter { ids.contains($0.id) }.map { "\($0.key) = \($0.value)" }.joined(separator: "\n")
    }
}

struct Ring: View {
    let value: Double?
    let title: LocalizedStringKey
    let detail: String
    let color: Color
    var charging = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = 0.0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(.quaternary, lineWidth: 14)
                Circle()
                    .trim(from: 0, to: min(shown, 1))
                    .stroke(color.gradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: charging ? color.opacity(0.55) : .clear, radius: 8)
                if charging && !reduceMotion {
                    ChargeFlow(fill: min(shown, 1))
                        .transition(.opacity)
                }
                Text(value.map { $0.formatted(.percent.precision(.fractionLength(0))) } ?? "–")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .liveValue(value)
                if charging {
                    Image(systemName: "bolt.fill")
                        .font(.title3)
                        .foregroundStyle(color.gradient)
                        .symbolEffect(.breathe, isActive: !reduceMotion)
                        .offset(y: -34)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? nil : .bouncy, value: charging)
            .frame(width: 140, height: 140)
            Text(title).font(.headline)
            Text(detail).font(.caption).foregroundStyle(.secondary).monospacedDigit()
        }
        .animation(.smooth, value: color)
        // Sweeps in on first appearance, then follows live updates.
        .onChange(of: value, initial: true) { old, new in
            withAnimation(reduceMotion ? nil : .smooth(duration: old == new ? 0.9 : 0.4)) { shown = new ?? 0 }
        }
        .accessibilityElement(children: .combine)
    }
}

/// A bright streak that keeps running along the filled arc while charging, like energy flowing in.
private struct ChargeFlow: View {
    let fill: Double
    private let period = 1.8
    private let length = 0.14

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
            let head = (0.5 - cos(.pi * t) / 2) * (fill + length)
            let tail = max(0, head - length)
            Circle()
                .trim(from: tail, to: min(head, fill))
                .stroke(
                    AngularGradient(colors: [.white.opacity(0), .white.opacity(0.85)],
                                    center: .center, startAngle: .degrees(tail * 360), endAngle: .degrees(head * 360)),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct Tile: View {
    let title: LocalizedStringKey
    let symbol: String
    let value: String
    var detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .liveValue(value)
            Text(detail ?? " ").font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: .rect(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}

/// Rolls changing digits of live readings instead of hard-cutting them every refresh.
private struct LiveValue<V: Equatable>: ViewModifier {
    let value: V
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .contentTransition(reduceMotion ? .opacity : .numericText())
            .animation(.snappy, value: value)
    }
}

extension View {
    func liveValue<V: Equatable>(_ value: V) -> some View { modifier(LiveValue(value: value)) }
}

extension BatteryInfo {
    var batterySymbol: String {
        if isCharging == true { return "battery.100percent.bolt" }
        return switch chargePercent ?? 100 {
        case ..<13: "battery.0percent"
        case ..<38: "battery.25percent"
        case ..<63: "battery.50percent"
        case ..<88: "battery.75percent"
        default: "battery.100percent"
        }
    }

    var statusText: String {
        if isCharging == true { return String(localized: "Charging") }
        if fullyCharged == true { return String(localized: "Fully charged") }
        if externalConnected == true { return String(localized: "On power adapter, not charging") }
        return String(localized: "On battery")
    }
}

func healthColor(_ health: Double?) -> Color {
    switch health ?? 1 {
    case 0.8...: .green
    case 0.6..<0.8: .orange
    default: .red
    }
}

func format(_ value: Int?, _ unit: String) -> String {
    guard let value else { return "–" }
    return unit.isEmpty ? "\(value)" : "\(value) \(unit)"
}

enum TemperatureUnit: String {
    case celsius, fahrenheit

    var symbol: String { self == .celsius ? "°C" : "°F" }
    func convert(_ celsius: Double) -> Double { self == .celsius ? celsius : celsius * 9 / 5 + 32 }
}

func format(_ celsius: Double?, _ unit: TemperatureUnit) -> String {
    celsius.map { unit.convert($0).formatted(.number.precision(.fractionLength(1))) + " " + unit.symbol } ?? "–"
}

func format(watts: Double?) -> String {
    watts.map { $0.formatted(.number.precision(.fractionLength(1))) + " W" } ?? "–"
}

func formatHours(_ hours: Int, minutes: Int? = nil) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = minutes == nil ? [.year, .day, .hour] : [.hour, .minute]
    formatter.maximumUnitCount = 2
    return formatter.string(from: TimeInterval((hours * 60 + (minutes ?? 0)) * 60)) ?? "\(hours) h"
}
