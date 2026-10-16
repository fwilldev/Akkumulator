<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – Mac, iPhone, iPad의 배터리 성능 상태 확인" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="MIT license"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Support on Ko-fi"></a>
</p>


# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · **한국어** · [日本語](README.ja.md)

Akkumulator는 macOS용 무료 오픈 소스 배터리 성능 상태 앱입니다. MacBook 배터리는 물론, 연결했거나 Wi-Fi로 페어링한 iPhone과 iPad의 배터리 상태도 보여 줍니다. 성능 상태, 사이클 수, 용량, 온도 등 다양한 정보를 확인할 수 있습니다.

## 왜 Akkumulator인가요?

다른 배터리 앱과의 비교(2026년 10월 기준):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| 가격 | 무료 | 무료, Plus는 유료 | 무료, 정식 버전 $4.99 | 유료 | 유료 |
| 오픈 소스 | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| iPhone/iPad 배터리 성능 상태 | ✓ | ✓ | ✓ | ✗ | ✓ |
| Wi-Fi로 iPhone/iPad 확인 | ✓ | Plus | ✓ | ✗ | – |
| Bluetooth 액세서리(충전량) | ✓ | ✗ | ✓ | ✓ | ✓ |
| iCloud로 기록 동기화 | ✓ | ✗ | – | – | ✗ |
| coconutBattery 기록 가져오기 | ✓ | – | – | – | – |
| 게이지 원시 데이터 | ✓ | Plus | – | – | – |

– = 제공하지 않거나 문서화되어 있지 않음. iStat Menus는 iPhone이나 iPad의 배터리 성능 상태가 아니라 Bluetooth 액세서리의 충전량을 보여 줍니다. Akkumulator에는 계정도 추적도 없습니다. 유일한 네트워크 요청은 업데이트 확인입니다.

## 기능

- Mac 배터리의 충전량, 성능 상태, 사이클 수, 온도, 전압, 전류, 전력 사용량. 전원 어댑터, 셀별 전압, 전체 수명 통계, 일련번호, 제조일도 확인할 수 있습니다.
- USB 또는 Wi-Fi로 연결된 iPhone과 iPad도 같은 정보를 확인할 수 있습니다. Apple Watch는 충전량만 보고합니다.
- AirPods(왼쪽, 오른쪽, 케이스), 키보드, 마우스 등 Bluetooth 액세서리의 충전량.
- 기기당 하루에 한 번, 또는 버튼을 누를 때마다 스냅샷을 저장합니다. 기록은 차트와 정렬 가능한 표로 표시되며 CSV로 내보낼 수 있습니다.
- 기록은 iCloud를 통해 Mac 간에 동기화됩니다.
- coconutBattery의 `.ccba` 내보내기 파일에서 가져올 수 있습니다. 중복 항목은 건너뛰며, coconutBattery가 설치되어 있어야 합니다.
- 원하면 사용할 수 있는 메뉴 막대 항목. 아이콘 또는 현재 충전량을 표시합니다.
- Mac 또는 iOS 기기의 배터리가 지정한 기준값 아래로 떨어지면 알림을 보냅니다.
- 배터리가 보고하는 모든 IORegistry 값을 보여 주는 원시 데이터 보기.
- 스스로 업데이트됩니다.
- 라이트 모드와 다크 모드.
- 영어, 독일어, 프랑스어, 스페인어, 이탈리아어, 포르투갈어(포르투갈 및 브라질), 중국어 간체, 한국어, 일본어.

## 설치

1. [Releases](https://github.com/fwilldev/Akkumulator/releases/latest)에서 최신 `Akkumulator-x.y.z.dmg`를 다운로드합니다.
2. DMG를 열고 **Akkumulator**를 **응용 프로그램**으로 드래그합니다.
3. 앱을 엽니다. 이 앱은 Developer ID로 서명되고 Apple에서 공증을 받았으므로 macOS에서 경고가 표시되지 않습니다.

이후에는 Akkumulator가 스스로 업데이트됩니다. 직접 확인하려면 **Akkumulator › 업데이트 확인…**을 사용하십시오.

### 요구 사항

- Apple 실리콘이 탑재된 Mac(M1 이상)
- macOS 15 Sequoia 이상
- iPhone/iPad: 기기의 잠금을 해제하고 **이 컴퓨터 신뢰**를 한 번 탭하십시오

## 자주 묻는 질문

**Mac에서 iPhone 배터리 성능 상태를 어떻게 확인하나요?**
케이블로 iPhone을 연결하거나(한 번 페어링한 뒤에는 같은 Wi-Fi에서도 가능), 잠금을 해제하고 이 Mac을 신뢰하십시오. 사이드바의 *연결됨* 아래에 나타나며 성능 상태, 사이클 수, 용량을 확인할 수 있습니다.

**coconutBattery 기록을 가져올 수 있나요?**
네, **파일 › coconutBattery 데이터 가져오기…**를 사용하십시오. coconutBattery가 같은 Mac에 설치되어 있어야 합니다. 내보내기 파일이 암호화되어 있으며, Akkumulator는 키를 앱에 포함하지 않고 설치된 앱에서 읽어 오기 때문입니다. Akkumulator는 일련번호로 기기를 구분하므로 가져온 항목과 새 항목이 하나의 기록으로 합쳐집니다.

**왜 Mac App Store에 없나요?**
iPhone과 iPad 데이터를 읽으려면 Apple의 비공개 `MobileDevice.framework`가 필요한데, App Store 앱은 이를 사용할 수 없습니다. 같은 이유로 이 앱은 샌드박스가 적용되지 않습니다.

**데이터를 어딘가로 전송하나요?**
아니요. 배터리 데이터는 Mac에만 저장됩니다(동기화를 켠 경우 iCloud에도 저장됩니다). 유일한 네트워크 요청은 이 저장소의 릴리스에서 업데이트를 확인하는 것입니다.

## 소스에서 빌드하기

Xcode 26 이상이 필요합니다.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

또는 `Akkumulator.xcodeproj`를 열고 Run을 누르십시오. Apple 개발자 계정 없이 빌드하려면 서명을 *Sign to Run Locally*로 설정하고 iCloud 기능을 제거하십시오. 권한이 없으면 앱이 스스로 동기화를 끕니다.

### 프로젝트 구성

| 파일 | 용도 |
|---|---|
| `BatteryInfo.swift` | 데이터 모델과 IORegistry 파서(이전 및 새 레이아웃, macOS 및 iOS 26 이상의 pack/bank/cell 하위 항목 포함) |
| `MacBattery.swift` | IOKit으로 `AppleSmartBattery` 읽기 |
| `MobileDevice.swift` | `MobileDevice.framework` 로드, 기기 감지, `diagnostics_relay` 조회 |
| `Accessories.swift` | IOPowerSources로 Bluetooth 액세서리의 충전량을 읽음 |
| `CoconutImport.swift` | `.ccba` 가져오기 |
| `BatteryStore.swift` | 실시간 상태, 새로 고침(Mac은 10초, iOS는 60초마다), SwiftData 모델, 스냅샷, 알림 |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | UI |

기록은 `~/Library/Application Support/Akkumulator/History.store`에 저장됩니다.

### 릴리스

`./scripts/release.sh 1.2.0 notes.md`은 앱을 빌드하고, Developer ID로 서명하고, DMG를 공증하고, Sparkle용으로 서명한 다음, DMG와 `appcast.xml`이 포함된 GitHub 릴리스를 게시합니다. Xcode에 팀 계정이 로그인되어 있어야 하고, `xcrun notarytool store-credentials`로 만든 `notary` 프로필과 로그인 키체인의 Sparkle 키가 필요하므로 제 Mac에서 실행합니다.

## 기여하기

버그 신고, 번역, pull request를 환영합니다. 큰 변경은 먼저 [issue](https://github.com/fwilldev/Akkumulator/issues)를 열어 주십시오. 문자열은 `Akkumulator/Localizable.xcstrings`에 있으며, Xcode가 빌드할 때 새 문자열을 추가합니다.

## 후원

Akkumulator는 무료이며 앞으로도 그럴 것입니다. Genius Bar에 가는 수고를 덜어 드렸다면 [Ko-fi](https://ko-fi.com/fwilldev)에서 커피 한 잔을 사 주실 수 있습니다.

## 라이선스

[MIT](LICENSE). Apple과 관련이 없습니다.
