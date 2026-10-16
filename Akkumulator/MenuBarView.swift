import SwiftUI

struct MenuBarView: View {
    @Environment(BatteryStore.self) private var store
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.allLive.isEmpty && store.accessories.isEmpty {
                Text("No battery found").foregroundStyle(.secondary)
            }
            ForEach(store.allLive) { info in
                MenuDeviceRow(info: info)
                Divider()
            }
            if !store.accessories.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(store.accessories) { accessory in
                        HStack {
                            Label(accessory.name, systemImage: accessory.symbol).lineLimit(1)
                            Spacer()
                            if accessory.isCharging {
                                Image(systemName: "bolt.fill").font(.caption).foregroundStyle(.green)
                            }
                            Text(accessory.parts.count == 1 ? "\(accessory.parts[0].percent) %" : accessory.partsText)
                                .font(.caption).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                }
                Divider()
            }
            HStack {
                Button("Open Akkumulator") {
                    openWindow(id: "main")
                    NSApp.activate()
                }
                Spacer()
                SettingsLink { Image(systemName: "gearshape") }
                    .help("Settings")
                Button("Quit", systemImage: "power") { NSApp.terminate(nil) }
                    .labelStyle(.iconOnly)
                    .help("Quit Akkumulator")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(width: 320)
    }
}

private struct MenuDeviceRow: View {
    let info: BatteryInfo
    @AppStorage(Defaults.temperatureUnit) private var tempUnit = TemperatureUnit.celsius

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text(info.name).font(.headline).lineLimit(1)
            } icon: {
                Image(systemName: info.kind.symbol)
            }
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 3) {
                GridRow {
                    item("Charge", info.chargePercent.map { "\($0) %" } ?? "–")
                    item("Health", info.health?.formatted(.percent.precision(.fractionLength(1))) ?? "–", color: healthColor(info.health))
                }
                GridRow {
                    item("Cycles", format(info.cycleCount, ""))
                    item("Temperature", format(info.temperature, tempUnit))
                }
                GridRow {
                    item("Power", format(watts: info.batteryWatts))
                    item("Capacity", format(info.fullChargeCapacity, "mAh"))
                }
            }
            Text(info.statusText).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func item(_ title: LocalizedStringKey, _ value: String, color: Color = .primary) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).monospacedDigit().foregroundStyle(color).liveValue(value)
        }
    }
}
