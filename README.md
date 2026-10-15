<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – battery health for your Mac, iPhone and iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Latest release"></a>
  <a href="https://github.com/fwilldev/Akkumulator/releases"><img src="https://img.shields.io/github/downloads/fwilldev/Akkumulator/total?color=0a2a8a" alt="Downloads"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="MIT license"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Support on Ko-fi"></a>
</p>

# Akkumulator

Akkumulator is a free, open-source battery health app for macOS. It reads the battery of your MacBook and of any iPhone or iPad connected over USB or Wi-Fi: health in percent, cycle count, full charge vs. design capacity, temperature, charging power, cell voltages and more.

## Features

- **Mac battery details**: charge, health (full charge / design capacity), cycle count, temperature, voltage, current, power draw, power adapter, per-cell voltages and Qmax, lifetime data (operating time, min/max temperature and currents), serial number and manufacture date.
- **iPhone and iPad battery health on your Mac**: the same values for any trusted iOS or iPadOS device connected via USB or Wi-Fi. Apple Watch shows the charge level.
- **History**: one snapshot per device per day (automatic, can be turned off) or on demand, with charts, a sortable table and CSV export.
- **iCloud sync** of your history between Macs.
- **coconutBattery import**: reads `.ccba` export files and skips duplicates (coconutBattery must be installed).
- **Optional menu bar item**, showing an icon or the current charge.
- **Low battery notifications** with a threshold for Mac and for iOS devices.
- **Raw data view** listing every IORegistry value the battery reports.
- **Automatic updates** through [Sparkle](https://sparkle-project.org).
- Light and Dark Mode, native SwiftUI.
- Available in English, German, French, Spanish, Italian, Portuguese (Portugal and Brazil), Simplified Chinese, Korean and Japanese.

## Installation

1. Download the latest `Akkumulator-x.y.z.dmg` from [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Open the DMG and drag **Akkumulator** into **Applications**.
3. Open it. The app is signed with a Developer ID and notarized by Apple.

After that, Akkumulator updates itself. You can also use **Akkumulator › Check for Updates…**.

### Requirements

- A Mac with Apple Silicon (M1 or later)
- macOS 15 Sequoia or later
- For iPhone/iPad: unlock the device and tap **Trust This Computer** once

## FAQ

**How do I check my iPhone battery health on a Mac?**
Connect the iPhone with a cable (or on the same Wi-Fi after it has been paired once), unlock it and trust the Mac. It shows up in the sidebar under *Connected*, with health, cycle count and capacity.

**Can I import my coconutBattery history?**
Yes, via **File › Import coconutBattery Data…**. The import needs coconutBattery installed on the same Mac, because the export files are encrypted and Akkumulator reads the key from coconutBattery instead of shipping it. Devices are identified by serial number, so imported and new history line up.

**Why isn't it in the Mac App Store?**
Reading iPhone and iPad data needs Apple's private `MobileDevice.framework`, which App Store apps can't use. For the same reason the app isn't sandboxed.

**Does it send data anywhere?**
No. Battery data stays on your Mac (and in your iCloud, if you turn sync on). The only network request is the update check against this repository's releases.

## Building from source

Requires Xcode 26 or later.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Or open `Akkumulator.xcodeproj` and press Run. To build without an Apple developer account, set signing to *Sign to Run Locally* and remove the iCloud capability; the app turns sync off by itself when the entitlement is missing.

### Project layout

| File | Purpose |
|---|---|
| `BatteryInfo.swift` | Data model and IORegistry parser (old and new layouts, including the pack/bank/cell children on macOS and iOS 26+) |
| `MacBattery.swift` | Reads `AppleSmartBattery` via IOKit |
| `MobileDevice.swift` | Loads `MobileDevice.framework`, listens for devices, queries `diagnostics_relay` |
| `CoconutImport.swift` | `.ccba` import |
| `BatteryStore.swift` | Live state, refresh (Mac every 10 s, iOS every 60 s), SwiftData model, snapshots, notifications |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | UI |

History is stored in `~/Library/Application Support/Akkumulator/History.store`.

### Releases

`./scripts/release.sh 1.2.0` archives the app, exports it with Developer ID, notarizes and staples the DMG, signs it for Sparkle and publishes a GitHub release with the DMG and `appcast.xml`. It runs on the maintainer's Mac: it needs Xcode signed in to the team, a `notary` profile from `xcrun notarytool store-credentials` and the Sparkle EdDSA key in the login keychain.

## Known limitations

- **Manufacture date**: 17-character battery serials carry the last digit of the year at position 4 and the ISO week at positions 5–6 (e.g. `F8Y`·`2`·`09`… = week 9 of 2022); the decade comes from the operating time. The 18-character serials of newer iPhones (iPhone 15 and later) don't follow this scheme, so only *First use* and operating time are shown there.
- **coconutBattery import**: the `.ccba` format was reverse-engineered from coconutBattery 4.4 (AES-256-GCM → LZFSE → JSON, with LZ4-compressed NSKeyedArchiver dumps per record). If coconutBattery changes it, the import fails with an error message.
- No Intel Mac support, no SSD info and no online sharing.

## Contributing

Bug reports, translations and pull requests are welcome. Open an [issue](https://github.com/fwilldev/Akkumulator/issues) first for bigger changes. Strings live in `Akkumulator/Localizable.xcstrings`; Xcode adds new ones at build time.

## Support

Akkumulator is free and will stay that way. If it saved you a trip to the Genius Bar, you can buy me a coffee on [Ko-fi](https://ko-fi.com/fwilldev).

## License

[MIT](LICENSE). Not affiliated with Apple.
