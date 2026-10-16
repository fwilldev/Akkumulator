<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – l’état de la batterie de votre Mac, iPhone et iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Dernière version"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="Licence MIT"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Soutenir sur Ko-fi"></a>
</p>

# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · **Français** · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

Akkumulator est une application gratuite et open source pour macOS qui affiche l’état de la batterie. Elle indique comment va la batterie de votre MacBook, ainsi que celle de tout iPhone ou iPad branché ou appairé en Wi-Fi : état, nombre de cycles, capacité, température et bien d’autres choses.

## Pourquoi Akkumulator ?

Comparaison avec d’autres applications de batterie (en octobre 2026) :

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Prix | Gratuit | Gratuit, Plus payant | Gratuit, version complète 4,99 $ | Payant | Payant |
| Open source | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| État de la batterie de l’iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad en Wi-Fi | ✓ | Plus | ✓ | ✗ | – |
| Accessoires Bluetooth (charge) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Historique synchronisé via iCloud | ✓ | ✗ | – | – | ✗ |
| Import de l’historique coconutBattery | ✓ | – | – | – | – |
| Données brutes de la jauge | ✓ | Plus | – | – | – |

– = non proposé ou non documenté. iStat Menus affiche la charge des accessoires Bluetooth, pas l’état de la batterie d’un iPhone ou d’un iPad. Akkumulator n’exige aucun compte et n’effectue aucun suivi : la seule requête réseau est la recherche de mises à jour.

## Fonctionnalités

- Charge, état, nombre de cycles, température, tension, courant et puissance absorbée de la batterie du Mac. Ainsi que l’adaptateur secteur, la tension de chaque cellule, les statistiques de durée de vie, le numéro de série et la date de fabrication.
- Les mêmes mesures pour les iPhone et iPad connectés en USB ou en Wi-Fi. Une Apple Watch ne signale que son niveau de charge.
- La charge des accessoires Bluetooth comme les AirPods (gauche, droit et boîtier), claviers et souris.
- Un instantané par appareil et par jour, ou à chaque clic sur le bouton. L’historique s’affiche sous forme de graphique et de tableau triable, et peut être exporté en CSV.
- L’historique est synchronisé entre vos Mac via iCloud.
- Import depuis les exports `.ccba` de coconutBattery. Les doublons sont ignorés ; coconutBattery doit être installé.
- Un élément dans la barre des menus si vous le souhaitez, avec une icône ou la charge actuelle.
- Une notification lorsque le Mac ou un appareil iOS passe sous un seuil que vous choisissez.
- Une vue des données brutes avec toutes les valeurs IORegistry que la batterie fournit.
- Se met à jour tout seul.
- Mode clair et mode sombre.
- Anglais, allemand, français, espagnol, italien, portugais (Portugal et Brésil), chinois simplifié, coréen et japonais.

## Installation

1. Téléchargez le dernier `Akkumulator-x.y.z.dmg` depuis [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Ouvrez le DMG et faites glisser **Akkumulator** dans **Applications**.
3. Ouvrez l’application. Elle est signée avec un Developer ID et notarisée par Apple, macOS n’affichera donc pas d’avertissement.

Ensuite, Akkumulator se met à jour tout seul. Pour vérifier manuellement : **Akkumulator › Rechercher des mises à jour…**.

### Configuration requise

- Un Mac avec Apple Silicon (M1 ou plus récent)
- macOS 15 Sequoia ou version ultérieure
- Pour iPhone/iPad : déverrouillez l’appareil et touchez une fois **Se fier à cet ordinateur**

## FAQ

**Comment vérifier l’état de la batterie de mon iPhone sur un Mac ?**
Branchez l’iPhone avec un câble (ou sur le même réseau Wi-Fi après un premier appairage), déverrouillez-le et faites confiance au Mac. Il apparaît dans la barre latérale sous *Connecté*, avec l’état, le nombre de cycles et la capacité.

**Puis-je importer mon historique coconutBattery ?**
Oui, via **Fichier › Importer les données coconutBattery…**. coconutBattery doit être installé sur le même Mac : ses fichiers d’export sont chiffrés, et Akkumulator lit la clé dans l’application installée au lieu de l’embarquer. Akkumulator associe les appareils par numéro de série, si bien que les entrées importées et les nouvelles se retrouvent dans le même historique.

**Pourquoi n’est-elle pas sur le Mac App Store ?**
Lire les données d’un iPhone ou d’un iPad nécessite le `MobileDevice.framework` privé d’Apple, que les apps de l’App Store ne peuvent pas utiliser. Pour la même raison, l’app n’est pas dans le sandbox.

**Envoie-t-elle des données quelque part ?**
Non. Les données de batterie restent sur votre Mac (et dans votre iCloud, si vous activez la synchronisation). La seule requête réseau est la recherche de mises à jour dans les releases de ce dépôt.

## Compiler depuis les sources

Nécessite Xcode 26 ou version ultérieure.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Ou ouvrez `Akkumulator.xcodeproj` et cliquez sur Run. Pour compiler sans compte développeur Apple, réglez la signature sur *Sign to Run Locally* et retirez la capability iCloud ; l’app désactive elle-même la synchronisation quand l’autorisation est absente.

### Structure du projet

| Fichier | Rôle |
|---|---|
| `BatteryInfo.swift` | Modèle de données et analyseur IORegistry (anciennes et nouvelles structures, y compris les enfants pack/bank/cell sous macOS et iOS 26+) |
| `MacBattery.swift` | Lit `AppleSmartBattery` via IOKit |
| `MobileDevice.swift` | Charge `MobileDevice.framework`, détecte les appareils, interroge `diagnostics_relay` |
| `Accessories.swift` | Lit la charge des accessoires Bluetooth via IOPowerSources |
| `CoconutImport.swift` | Import `.ccba` |
| `BatteryStore.swift` | État en direct, actualisation (Mac toutes les 10 s, iOS toutes les 60 s), modèle SwiftData, instantanés, notifications |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | Interface |

L’historique est stocké dans `~/Library/Application Support/Akkumulator/History.store`.

### Releases

`./scripts/release.sh 1.2.0` compile l’app, la signe avec Developer ID, notarise le DMG, le signe pour Sparkle et publie une release GitHub avec le DMG et `appcast.xml`. Le script tourne sur mon Mac, car il faut Xcode connecté à l’équipe, un profil `notary` créé avec `xcrun notarytool store-credentials` et la clé Sparkle dans le trousseau de session.

## Contribuer

Les rapports de bugs, traductions et pull requests sont les bienvenus. Pour les changements importants, ouvrez d’abord une [issue](https://github.com/fwilldev/Akkumulator/issues). Les chaînes se trouvent dans `Akkumulator/Localizable.xcstrings` ; Xcode ajoute les nouvelles à la compilation.

## Soutien

Akkumulator est gratuit et le restera. Si l’app vous a évité un passage au Genius Bar, vous pouvez m’offrir un café sur [Ko-fi](https://ko-fi.com/fwilldev).

## Licence

[MIT](LICENSE). Sans lien avec Apple.
