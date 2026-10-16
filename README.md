<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – battery health for your Mac, iPhone and iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="MIT license"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Support on Ko-fi"></a>
</p>

# Akkumulator

Akkumulator is a free, open-source battery health app for macOS. It tells you how your MacBook's battery is doing, and the battery of any iPhone or iPad you plug in or pair over Wi-Fi: health, cycle count, capacity, temperature and quite a bit more.

## Why Akkumulator?

How it compares with [coconutBattery](https://www.coconut-flavour.com/coconutbattery/), [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast), [iStat Menus](https://bjango.com/mac/istatmenus/) and [Juicy](https://getjuicy.app) (as of October 2026):

- All of it is free. There's no Plus tier, license key or trial. coconutBattery sells a Plus upgrade, Mac 4 Breakfast costs $4.99 for the full version, and iStat Menus and Juicy are paid apps.
- It's open source (MIT), so you can read exactly what the app does with your devices. The other four are closed source.
- iPhones and iPads work over Wi-Fi too, at no extra cost. In coconutBattery, Wi-Fi is a Plus feature. iStat Menus shows the charge of Bluetooth accessories, but not the battery health of an iPhone or iPad.
- Your history can follow you to every Mac through iCloud, if you turn sync on. Juicy, for example, keeps everything on one Mac.
- You can bring your coconutBattery history along. Akkumulator imports `.ccba` exports and matches devices by serial number, so old and new entries end up in one timeline.
- Nothing is hidden behind a paywall: per-cell voltages, lifetime minimums and maximums, and a raw view of every value the battery gauge reports.
- No account and no tracking. The only network request is the update check.

## Features

- Charge, health, cycle count, temperature, voltage, current and power draw of your Mac's battery. Also the power adapter, per-cell voltages, lifetime stats, serial number and manufacture date.
- The same readings for iPhones and iPads connected over USB or Wi-Fi. An Apple Watch only reports its charge level.
- One snapshot per device and day, or whenever you click the button. History shows up as a chart and a sortable table, and you can export it as CSV.
- History syncs between your Macs through iCloud.
- Import from coconutBattery `.ccba` exports. Duplicates are skipped; coconutBattery has to be installed.
- A menu bar item if you want one, with an icon or the current charge.
- A notification when the Mac or an iOS device drops below a threshold you pick.
- A raw data view with every IORegistry value the battery reports.
- Updates itself through [Sparkle](https://sparkle-project.org).
- Light and Dark Mode.
- English, German, French, Spanish, Italian, Portuguese (Portugal and Brazil), Simplified Chinese, Korean and Japanese.

## Installation

1. Download the latest `Akkumulator-x.y.z.dmg` from [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Open the DMG and drag **Akkumulator** into **Applications**.
3. Open it. The app is signed with a Developer ID and notarized by Apple, so macOS won't complain.

From then on Akkumulator updates itself. To check by hand, use **Akkumulator › Check for Updates…**.

### Requirements

- A Mac with Apple Silicon (M1 or later)
- macOS 15 Sequoia or later
- For iPhone/iPad: unlock the device and tap **Trust This Computer** once

## FAQ

**How do I check my iPhone battery health on a Mac?**
Connect the iPhone with a cable (or on the same Wi-Fi after it has been paired once), unlock it and trust the Mac. It shows up in the sidebar under *Connected*, with health, cycle count and capacity.

**Can I import my coconutBattery history?**
Yes, via **File › Import coconutBattery Data…**. coconutBattery has to be installed on the same Mac: its export files are encrypted, and Akkumulator reads the key from the installed app instead of shipping it. Akkumulator matches devices by serial number, so imported entries and new ones end up in the same history.

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

`./scripts/release.sh 1.2.0` builds the app, signs it with Developer ID, notarizes the DMG, signs it for Sparkle and publishes a GitHub release with the DMG and `appcast.xml`. It runs on my Mac, since it needs Xcode signed in to the team, a `notary` profile from `xcrun notarytool store-credentials` and the Sparkle key in the login keychain.

## Contributing

Bug reports, translations and pull requests are welcome. Open an [issue](https://github.com/fwilldev/Akkumulator/issues) first for bigger changes. Strings live in `Akkumulator/Localizable.xcstrings`; Xcode adds new ones at build time.

## Support

Akkumulator is free and will stay that way. If it saved you a trip to the Genius Bar, you can buy me a coffee on [Ko-fi](https://ko-fi.com/fwilldev).

## License

[MIT](LICENSE). Not affiliated with Apple.
