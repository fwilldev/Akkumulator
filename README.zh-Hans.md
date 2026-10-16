<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – 适用于 Mac、iPhone 和 iPad 的电池健康工具" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="MIT license"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Support on Ko-fi"></a>
</p>


# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · **简体中文** · [한국어](README.ko.md) · [日本語](README.ja.md)

Akkumulator 是一款免费、开源的 macOS 电池健康应用。它能告诉你 MacBook 的电池状况，也能读取通过 USB 连接或经 Wi-Fi 配对的任何 iPhone 或 iPad 的电池信息：健康度、循环计数、容量、温度等等。

## 为什么选择 Akkumulator？

与其他电池应用的对比（截至 2026 年 10 月）：

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| 价格 | 免费 | 免费，Plus 版付费 | 免费，完整版 $4.99 | 付费 | 付费 |
| 开源 | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| iPhone/iPad 电池健康 | ✓ | ✓ | ✓ | ✗ | ✓ |
| 通过 Wi-Fi 读取 iPhone/iPad | ✓ | Plus | ✓ | ✗ | – |
| 蓝牙配件（电量） | ✓ | ✗ | ✓ | ✓ | ✓ |
| 通过 iCloud 同步历史记录 | ✓ | ✗ | – | – | ✗ |
| 导入 coconutBattery 历史记录 | ✓ | – | – | – | – |
| 电量计原始数据 | ✓ | Plus | – | – | – |

– = 未提供或无相关文档。iStat Menus 显示的是蓝牙配件的电量，而不是 iPhone 或 iPad 的电池健康。Akkumulator 无需账户，也不做任何跟踪：唯一的网络请求是检查更新。

## 功能

- 显示 Mac 电池的电量、健康度、循环计数、温度、电压、电流和功率，还包括电源适配器、各电芯电压、生命周期统计、序列号和生产日期。
- 通过 USB 或 Wi-Fi 连接的 iPhone 和 iPad 可读取同样的数据。Apple Watch 只会报告电量。
- 蓝牙配件的电量，例如 AirPods（左耳、右耳和充电盒）、键盘和鼠标。
- 每台设备每天保存一份快照，也可随时点按按钮保存。历史记录以图表和可排序的表格显示，并可导出为 CSV。
- 历史记录通过 iCloud 在你的各台 Mac 之间同步。
- 可导入 coconutBattery 的 `.ccba` 导出文件。重复项会被跳过；需要已安装 coconutBattery。
- 可选的菜单栏项目，显示图标或当前电量。
- 当 Mac 或 iOS 设备的电量低于你设定的阈值时发出通知。
- 原始数据视图，列出电池报告的所有 IORegistry 值。
- 自动更新。
- 支持浅色和深色模式。
- 支持英语、德语、法语、西班牙语、意大利语、葡萄牙语（葡萄牙和巴西）、简体中文、韩语和日语。

## 安装

1. 从 [Releases](https://github.com/fwilldev/Akkumulator/releases/latest) 下载最新的 `Akkumulator-x.y.z.dmg`。
2. 打开 DMG，将 **Akkumulator** 拖到**应用程序**中。
3. 打开它。此 App 已使用 Developer ID 签名并经过 Apple 公证，因此 macOS 不会弹出警告。

此后 Akkumulator 会自动更新。若要手动检查，请选取 **Akkumulator › 检查更新…**。

### 系统要求

- 搭载 Apple 芯片的 Mac（M1 或更新机型）
- macOS 15 Sequoia 或更高版本
- 对于 iPhone/iPad：解锁设备并轻点一次**信任此电脑**

## 常见问题

**如何在 Mac 上查看 iPhone 的电池健康？**
用数据线连接 iPhone（或在配对一次后连接同一 Wi-Fi），解锁并信任这台 Mac。它会出现在边栏的*已连接*下方，显示健康度、循环计数和容量。

**可以导入我的 coconutBattery 历史记录吗？**
可以，选取 **文件 › 导入 coconutBattery 数据…**。coconutBattery 必须安装在同一台 Mac 上：其导出文件是加密的，Akkumulator 从已安装的 App 中读取密钥，而不是自带密钥。Akkumulator 通过序列号匹配设备，因此导入的条目和新记录会归入同一份历史记录。

**为什么它不在 Mac App Store 中？**
读取 iPhone 和 iPad 数据需要 Apple 的私有 `MobileDevice.framework`，而 App Store 的 App 无法使用它。出于同样的原因，此 App 没有启用沙盒。

**它会把数据发送到别处吗？**
不会。电池数据只保存在你的 Mac 上（如果开启同步，也会存在你的 iCloud 中）。唯一的网络请求是向本仓库的 releases 检查更新。

## 从源代码构建

需要 Xcode 26 或更高版本。

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

或者打开 `Akkumulator.xcodeproj` 并点按 Run。若要在没有 Apple 开发者账户的情况下构建，请将签名设为 *Sign to Run Locally* 并移除 iCloud 功能；缺少该权限时，App 会自动关闭同步。

### 项目结构

| 文件 | 用途 |
|---|---|
| `BatteryInfo.swift` | 数据模型和 IORegistry 解析器（新旧布局，包括 macOS 和 iOS 26+ 上的 pack/bank/cell 子节点） |
| `MacBattery.swift` | 通过 IOKit 读取 `AppleSmartBattery` |
| `MobileDevice.swift` | 加载 `MobileDevice.framework`，监听设备，查询 `diagnostics_relay` |
| `Accessories.swift` | 通过 IOPowerSources 读取蓝牙配件的电量 |
| `CoconutImport.swift` | `.ccba` 导入 |
| `BatteryStore.swift` | 实时状态、刷新（Mac 每 10 秒，iOS 每 60 秒）、SwiftData 模型、快照、通知 |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | 界面 |

历史记录存储在 `~/Library/Application Support/Akkumulator/History.store`。

### 发布

`./scripts/release.sh 1.2.0 notes.md` 会构建 App，使用 Developer ID 签名，对 DMG 进行公证，为 Sparkle 签名，并发布包含 DMG 和 `appcast.xml` 的 GitHub release。它在我自己的 Mac 上运行，因为需要 Xcode 登录团队账户、通过 `xcrun notarytool store-credentials` 创建的 `notary` 配置，以及登录钥匙串中的 Sparkle 密钥。

## 参与贡献

欢迎提交错误报告、翻译和 pull request。较大的改动请先开一个 [issue](https://github.com/fwilldev/Akkumulator/issues)。字符串位于 `Akkumulator/Localizable.xcstrings`；Xcode 会在构建时添加新的字符串。

## 支持

Akkumulator 是免费的，并将一直免费。如果它帮你省下了一趟 Genius Bar，可以在 [Ko-fi](https://ko-fi.com/fwilldev) 上请我喝杯咖啡。

## 许可证

[MIT](LICENSE)。与 Apple 无关联。
