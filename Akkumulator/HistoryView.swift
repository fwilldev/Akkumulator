import Charts
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct HistoryView: View {
    enum Metric: String, CaseIterable {
        case health = "Health", capacity = "Capacity", cycles = "Cycles", temperature = "Temperature"

        func value(_ sample: BatterySample, _ tempUnit: TemperatureUnit) -> Double? {
            switch self {
            case .health: sample.health.map { $0 * 100 }
            case .capacity: sample.fullChargeCapacity.map(Double.init)
            case .cycles: sample.cycleCount.map(Double.init)
            case .temperature: sample.temperature.map(tempUnit.convert)
            }
        }

        func unit(_ tempUnit: TemperatureUnit) -> String {
            switch self {
            case .health: "%"
            case .capacity: "mAh"
            case .cycles: ""
            case .temperature: tempUnit.symbol
            }
        }
    }

    let deviceID: String
    @Environment(\.modelContext) private var context
    @Query private var samples: [BatterySample]
    @State private var metric = Metric.health
    @AppStorage(Defaults.temperatureUnit) private var tempUnit = TemperatureUnit.celsius
    @State private var selection = Set<PersistentIdentifier>()
    @State private var sortOrder = [KeyPathComparator(\BatterySample.date, order: .reverse)]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(deviceID: String) {
        self.deviceID = deviceID
        _samples = Query(filter: #Predicate { $0.deviceID == deviceID }, sort: \.date)
    }

    var body: some View {
        if samples.isEmpty {
            ContentUnavailableView("No History Yet", systemImage: "chart.xyaxis.line",
                                   description: Text("Snapshots are saved automatically once a day, or via “Save Snapshot”."))
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Picker("Metric", selection: $metric) {
                        ForEach(Metric.allCases, id: \.self) { Text(LocalizedStringKey($0.rawValue)) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize()
                    Spacer()
                    Button("Delete", systemImage: "trash", action: deleteSelection)
                        .disabled(selection.isEmpty)
                    Button("Export CSV…", systemImage: "square.and.arrow.up", action: exportCSV)
                }

                Chart {
                    ForEach(samples) { sample in
                        if let value = metric.value(sample, tempUnit) {
                            LineMark(x: .value("Date", sample.date), y: .value(metric.rawValue, value))
                                .interpolationMethod(.monotone)
                            PointMark(x: .value("Date", sample.date), y: .value(metric.rawValue, value))
                                .symbolSize(20)
                        }
                    }
                    // Apple treats batteries below 80 % of design capacity as worn.
                    if metric == .health {
                        RuleMark(y: .value("Health", 80))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(.orange.opacity(0.7))
                    }
                }
                .chartYScale(domain: .automatic(includesZero: metric == .cycles))
                .animation(reduceMotion ? nil : .smooth, value: metric)
                .chartYAxisLabel(metric.unit(tempUnit))
                .frame(height: 200)

                Table(samples.sorted(using: sortOrder), selection: $selection, sortOrder: $sortOrder) {
                    TableColumn("Date", value: \.date) { Text($0.date.formatted(date: .abbreviated, time: .shortened)) }
                        .width(min: 150)
                    TableColumn("Health", value: \.sortHealth) { Text($0.health?.formatted(.percent.precision(.fractionLength(1))) ?? "–") }
                    TableColumn("Full Charge", value: \.sortFull) { Text(format($0.fullChargeCapacity, "mAh")) }
                    TableColumn("Design", value: \.sortDesign) { Text(format($0.designCapacity, "mAh")) }
                    TableColumn("Cycles", value: \.sortCycles) { Text(format($0.cycleCount, "")) }
                    TableColumn("Charge", value: \.sortCharge) { Text(format($0.chargePercent, "%")) }
                    TableColumn("Temperature", value: \.sortTemperature) { Text(format($0.temperature, tempUnit)) }
                }
                .monospacedDigit()
                .onDeleteCommand(perform: deleteSelection)
            }
            .padding()
        }
    }

    private func deleteSelection() {
        withAnimation(reduceMotion ? nil : .smooth) {
            for sample in samples where selection.contains(sample.id) { context.delete(sample) }
            try? context.save()
            selection.removeAll()
        }
    }

    private func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "\(samples.first?.deviceName ?? "Battery") History.csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let header = "date,device,model,charge_percent,full_charge_capacity_mah,design_capacity_mah,health_percent,cycle_count,temperature_c,voltage_mv"
        let rows = samples.map { s in
            let name = "\"" + s.deviceName.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            let fields: [String?] = [s.date.ISO8601Format(), name, s.model,
             s.chargePercent.map(String.init), s.fullChargeCapacity.map(String.init), s.designCapacity.map(String.init),
             s.health.map { String(format: "%.2f", $0 * 100) }, s.cycleCount.map(String.init),
             s.temperature.map { String(format: "%.2f", $0) }, s.voltage.map(String.init)]
            return fields.map { $0 ?? "" }.joined(separator: ",")
        }
        do {
            try ([header] + rows).joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

/// Table sorting needs non-optional Comparable values; missing values sort first.
private extension BatterySample {
    var sortHealth: Double { health ?? -1 }
    var sortFull: Int { fullChargeCapacity ?? -1 }
    var sortDesign: Int { designCapacity ?? -1 }
    var sortCycles: Int { cycleCount ?? -1 }
    var sortCharge: Int { chargePercent ?? -1 }
    var sortTemperature: Double { temperature ?? -999 }
}
