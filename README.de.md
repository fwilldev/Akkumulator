<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – Akkuzustand für Mac, iPhone und iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Neueste Version"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="MIT-Lizenz"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Auf Ko-fi unterstützen"></a>
</p>

# Akkumulator

[English](README.md) · **Deutsch** · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

Akkumulator ist eine kostenlose Open-Source-App für macOS, die den Zustand von Akkus anzeigt. Sie zeigt, wie es um den Akku des MacBook steht, und um den Akku jedes iPhones oder iPads, das per Kabel angeschlossen oder über WLAN gekoppelt ist: Zustand, Ladezyklen, Kapazität, Temperatur und einiges mehr.

## Warum Akkumulator?

Der Vergleich mit anderen Akku-Apps (Stand Oktober 2026):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Preis | Kostenlos | Kostenlos, Plus kostenpflichtig | Kostenlos, Vollversion 4,99 $ | Kostenpflichtig | Kostenpflichtig |
| Open Source | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| Akkuzustand von iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad über WLAN | ✓ | Plus | ✓ | ✗ | – |
| Bluetooth-Zubehör (Ladestand) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Verlauf per iCloud synchronisiert | ✓ | ✗ | – | – | ✗ |
| coconutBattery-Verlauf importieren | ✓ | – | – | – | – |
| Rohdaten des Gauge-Chips | ✓ | Plus | – | – | – |

– = nicht angeboten oder nicht dokumentiert. iStat Menus zeigt den Ladestand von Bluetooth-Zubehör, nicht den Akkuzustand von iPhone oder iPad. Akkumulator braucht kein Konto und trackt nichts: Die einzige Netzwerkanfrage ist die Update-Prüfung.

## Funktionen

- Ladung, Zustand, Ladezyklen, Temperatur, Spannung, Strom und Leistungsaufnahme des Mac-Akkus. Dazu Netzteil, Spannung der einzelnen Zellen, Lebensdauerwerte, Seriennummer und Herstellungsdatum.
- Dieselben Werte für iPhones und iPads, die per USB oder WLAN verbunden sind. Eine Apple Watch meldet nur ihren Ladestand.
- Der Ladestand von Bluetooth-Zubehör wie AirPods (links, rechts und Case), Tastaturen und Mäusen.
- Ein Snapshot pro Gerät und Tag, oder jederzeit per Klick auf die Schaltfläche. Der Verlauf erscheint als Diagramm und als sortierbare Tabelle und lässt sich als CSV exportieren.
- Der Verlauf wird über iCloud zwischen deinen Macs synchronisiert.
- Import aus `.ccba`-Exporten von coconutBattery. Duplikate werden übersprungen; coconutBattery muss installiert sein.
- Auf Wunsch ein Menüleistensymbol, mit Icon oder aktuellem Ladestand.
- Eine Mitteilung, wenn der Mac oder ein iOS-Gerät unter eine selbst gewählte Schwelle fällt.
- Eine Rohdatenansicht mit allen IORegistry-Werten, die der Akku meldet.
- Aktualisiert sich selbst.
- Heller und dunkler Modus.
- Englisch, Deutsch, Französisch, Spanisch, Italienisch, Portugiesisch (Portugal und Brasilien), vereinfachtes Chinesisch, Koreanisch und Japanisch.

## Installation

1. Die aktuelle `Akkumulator-x.y.z.dmg` von [Releases](https://github.com/fwilldev/Akkumulator/releases/latest) laden.
2. Das DMG öffnen und **Akkumulator** in **Programme** ziehen.
3. Die App öffnen. Sie ist mit einer Developer ID signiert und von Apple notarisiert, macOS meldet also keine Warnung.

Danach aktualisiert sich Akkumulator selbst. Für eine manuelle Prüfung: **Akkumulator › Nach Updates suchen …**.

### Voraussetzungen

- Ein Mac mit Apple Silicon (M1 oder neuer)
- macOS 15 Sequoia oder neuer
- Für iPhone/iPad: Gerät entsperren und einmalig auf **Diesem Computer vertrauen** tippen

## FAQ

**Wie prüfe ich den Akkuzustand meines iPhones am Mac?**
Das iPhone per Kabel anschließen (oder im selben WLAN, nachdem es einmal gekoppelt wurde), entsperren und dem Mac vertrauen. Es erscheint in der Seitenleiste unter *Verbunden*, mit Zustand, Ladezyklen und Kapazität.

**Kann ich meinen coconutBattery-Verlauf importieren?**
Ja, über **Ablage › coconutBattery-Daten importieren …**. coconutBattery muss auf demselben Mac installiert sein: Die Exportdateien sind verschlüsselt, und Akkumulator liest den Schlüssel aus der installierten App, statt ihn mitzuliefern. Akkumulator ordnet Geräte über die Seriennummer zu, importierte und neue Einträge landen also im selben Verlauf.

**Warum gibt es die App nicht im Mac App Store?**
Für das Auslesen von iPhone- und iPad-Daten wird Apples privates `MobileDevice.framework` gebraucht, das App-Store-Apps nicht nutzen dürfen. Aus demselben Grund läuft die App nicht in der Sandbox.

**Werden Daten irgendwohin gesendet?**
Nein. Akkudaten bleiben auf dem Mac (und in der eigenen iCloud, wenn die Synchronisierung eingeschaltet ist). Die einzige Netzwerkanfrage ist die Update-Prüfung gegen die Releases dieses Repositorys.

## Aus dem Quellcode bauen

Benötigt Xcode 26 oder neuer.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Oder `Akkumulator.xcodeproj` öffnen und auf Run klicken. Um ohne Apple-Entwicklerkonto zu bauen, das Signieren auf *Sign to Run Locally* stellen und die iCloud-Capability entfernen; die App schaltet die Synchronisierung selbst ab, wenn die Berechtigung fehlt.

### Projektstruktur

| Datei | Zweck |
|---|---|
| `BatteryInfo.swift` | Datenmodell und IORegistry-Parser (alte und neue Layouts, einschließlich der Pack-/Bank-/Cell-Unterknoten unter macOS und iOS 26+) |
| `MacBattery.swift` | Liest `AppleSmartBattery` über IOKit |
| `MobileDevice.swift` | Lädt `MobileDevice.framework`, erkennt Geräte, fragt `diagnostics_relay` ab |
| `Accessories.swift` | Liest den Ladestand von Bluetooth-Zubehör über IOPowerSources |
| `CoconutImport.swift` | `.ccba`-Import |
| `BatteryStore.swift` | Live-Zustand, Aktualisierung (Mac alle 10 s, iOS alle 60 s), SwiftData-Modell, Snapshots, Mitteilungen |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | UI |

Der Verlauf liegt in `~/Library/Application Support/Akkumulator/History.store`.

### Releases

`./scripts/release.sh 1.2.0 notes.md` baut die App, signiert sie mit Developer ID, notarisiert das DMG, signiert es für Sparkle und veröffentlicht ein GitHub-Release mit dem DMG und `appcast.xml`. Das Skript läuft auf meinem Mac, denn es braucht Xcode mit Anmeldung im Team, ein `notary`-Profil aus `xcrun notarytool store-credentials` und den Sparkle-Schlüssel im Anmeldeschlüsselbund.

## Mitmachen

Fehlerberichte, Übersetzungen und Pull Requests sind willkommen. Bei größeren Änderungen bitte zuerst ein [Issue](https://github.com/fwilldev/Akkumulator/issues) öffnen. Die Strings liegen in `Akkumulator/Localizable.xcstrings`; Xcode ergänzt neue beim Build.

## Unterstützen

Akkumulator ist kostenlos und bleibt es auch. Wenn dir die App einen Gang zum Apple Store erspart hat, kannst du mir auf [Ko-fi](https://ko-fi.com/fwilldev) einen Kaffee spendieren.

## Lizenz

[MIT](LICENSE). Nicht mit Apple verbunden.
