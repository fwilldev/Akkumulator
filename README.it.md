<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – lo stato della batteria per il tuo Mac, iPhone e iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Ultima versione"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="Licenza MIT"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Supporta su Ko-fi"></a>
</p>

# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · **Italiano** · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

Akkumulator è un'app gratuita e open source per controllare lo stato della batteria su macOS. Ti dice come sta la batteria del tuo MacBook e quella di qualsiasi iPhone o iPad che colleghi con il cavo o abbini tramite Wi-Fi: stato, numero di cicli, capacità, temperatura e parecchio altro.

## Perché Akkumulator?

Il confronto con le altre app per la batteria (a ottobre 2026):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Prezzo | Gratis | Gratis, Plus a pagamento | Gratis, versione completa $4.99 | A pagamento | A pagamento |
| Open source | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| Stato della batteria di iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad tramite Wi-Fi | ✓ | Plus | ✓ | ✗ | – |
| Accessori Bluetooth (carica) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Cronologia sincronizzata con iCloud | ✓ | ✗ | – | – | ✗ |
| Importazione della cronologia di coconutBattery | ✓ | – | – | – | – |
| Dati grezzi del gauge | ✓ | Plus | – | – | – |

– = non offerto o non documentato. iStat Menus mostra la carica degli accessori Bluetooth, non lo stato della batteria di iPhone o iPad. Akkumulator non richiede un account e non traccia nulla: l'unica richiesta di rete è il controllo degli aggiornamenti.

## Funzionalità

- Carica, stato, numero di cicli, temperatura, tensione, corrente e potenza assorbita della batteria del tuo Mac. Inoltre alimentatore, tensioni delle singole celle, statistiche di vita utile, numero di serie e data di produzione.
- Le stesse letture per iPhone e iPad collegati via USB o Wi-Fi. Un Apple Watch riporta solo il livello di carica.
- La carica degli accessori Bluetooth come AirPods (sinistro, destro e custodia), tastiere e mouse.
- Un'istantanea per dispositivo al giorno, oppure quando clicchi il pulsante. La cronologia compare come grafico e come tabella ordinabile, ed è esportabile in CSV.
- La cronologia si sincronizza tra i tuoi Mac tramite iCloud.
- Importazione dalle esportazioni `.ccba` di coconutBattery. I duplicati vengono saltati; coconutBattery deve essere installato.
- Un elemento nella barra dei menu, se lo vuoi, con un'icona o la carica attuale.
- Una notifica quando il Mac o un dispositivo iOS scende sotto una soglia che scegli tu.
- Una vista dei dati grezzi con tutti i valori IORegistry riportati dalla batteria.
- Si aggiorna da sola.
- Modalità Chiara e Scura.
- Inglese, tedesco, francese, spagnolo, italiano, portoghese (Portogallo e Brasile), cinese semplificato, coreano e giapponese.

## Installazione

1. Scarica l'ultimo `Akkumulator-x.y.z.dmg` da [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Apri il DMG e trascina **Akkumulator** in **Applicazioni**.
3. Aprila. L'app è firmata con un Developer ID e notarizzata da Apple, quindi macOS non avrà nulla da ridire.

Da quel momento Akkumulator si aggiorna da sola. Per controllare a mano, usa **Akkumulator › Verifica aggiornamenti…**.

### Requisiti

- Un Mac con Apple Silicon (M1 o successivi)
- macOS 15 Sequoia o successivo
- Per iPhone/iPad: sblocca il dispositivo e tocca **Autorizza questo computer** una volta

## FAQ

**Come controllo lo stato della batteria del mio iPhone su un Mac?**
Collega l'iPhone con un cavo (oppure sulla stessa rete Wi-Fi, dopo averlo abbinato una volta), sbloccalo e autorizza il Mac. Compare nella barra laterale sotto *Collegato*, con stato, numero di cicli e capacità.

**Posso importare la mia cronologia di coconutBattery?**
Sì, con **File › Importa dati di coconutBattery…**. coconutBattery deve essere installato sullo stesso Mac: i suoi file di esportazione sono cifrati e Akkumulator legge la chiave dall'app installata invece di includerla. Akkumulator associa i dispositivi tramite il numero di serie, quindi le voci importate e quelle nuove finiscono nella stessa cronologia.

**Perché non è nel Mac App Store?**
Per leggere i dati di iPhone e iPad serve il `MobileDevice.framework` privato di Apple, che le app dell'App Store non possono usare. Per lo stesso motivo l'app non è in sandbox.

**Invia dati da qualche parte?**
No. I dati della batteria restano sul tuo Mac (e nel tuo iCloud, se attivi la sincronizzazione). L'unica richiesta di rete è il controllo degli aggiornamenti sulle release di questo repository.

## Compilare dai sorgenti

Richiede Xcode 26 o successivo.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Oppure apri `Akkumulator.xcodeproj` e premi Run. Per compilare senza un account sviluppatore Apple, imposta la firma su *Sign to Run Locally* e rimuovi la capability iCloud; l'app disattiva la sincronizzazione da sola quando manca l'entitlement.

### Struttura del progetto

| File | Funzione |
|---|---|
| `BatteryInfo.swift` | Modello dati e parser di IORegistry (layout vecchi e nuovi, inclusi i figli pack/bank/cell su macOS e iOS 26+) |
| `MacBattery.swift` | Legge `AppleSmartBattery` tramite IOKit |
| `MobileDevice.swift` | Carica `MobileDevice.framework`, rileva i dispositivi, interroga `diagnostics_relay` |
| `Accessories.swift` | Legge la carica degli accessori Bluetooth tramite IOPowerSources |
| `CoconutImport.swift` | Importazione `.ccba` |
| `BatteryStore.swift` | Stato live, aggiornamento (Mac ogni 10 s, iOS ogni 60 s), modello SwiftData, istantanee, notifiche |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | Interfaccia |

La cronologia è salvata in `~/Library/Application Support/Akkumulator/History.store`.

### Release

`./scripts/release.sh 1.2.0 notes.md` compila l'app, la firma con Developer ID, notarizza il DMG, lo firma per Sparkle e pubblica una release su GitHub con il DMG e `appcast.xml`. Gira sul mio Mac, perché servono Xcode con l'accesso al team, un profilo `notary` creato con `xcrun notarytool store-credentials` e la chiave Sparkle nel portachiavi di login.

## Contribuire

Segnalazioni di bug, traduzioni e pull request sono benvenute. Per modifiche più grandi apri prima una [issue](https://github.com/fwilldev/Akkumulator/issues). Le stringhe stanno in `Akkumulator/Localizable.xcstrings`; Xcode aggiunge quelle nuove in fase di compilazione.

## Supporto

Akkumulator è gratuita e resterà tale. Se ti ha risparmiato un viaggio al Genius Bar, puoi offrirmi un caffè su [Ko-fi](https://ko-fi.com/fwilldev).

## Licenza

[MIT](LICENSE). Non affiliata ad Apple.
