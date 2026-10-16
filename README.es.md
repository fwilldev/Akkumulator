<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – el estado de la batería de tu Mac, iPhone y iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Última versión"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="Licencia MIT"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Apoyar en Ko-fi"></a>
</p>

# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · **Español** · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

Akkumulator es una app gratuita y de código abierto para macOS que muestra el estado de la batería. Te dice cómo está la batería de tu MacBook y la de cualquier iPhone o iPad que conectes o emparejes por Wi-Fi: estado, número de ciclos, capacidad, temperatura y bastante más.

## ¿Por qué Akkumulator?

Comparación con otras apps de batería (a octubre de 2026):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Precio | Gratis | Gratis, Plus de pago | Gratis, versión completa 4,99 $ | De pago | De pago |
| Código abierto | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| Estado de la batería del iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad por Wi-Fi | ✓ | Plus | ✓ | ✗ | – |
| Accesorios Bluetooth (carga) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Historial sincronizado con iCloud | ✓ | ✗ | – | – | ✗ |
| Importar el historial de coconutBattery | ✓ | – | – | – | – |
| Datos sin procesar del medidor | ✓ | Plus | – | – | – |

– = no ofrecido o no documentado. iStat Menus muestra la carga de los accesorios Bluetooth, no el estado de la batería del iPhone o del iPad. Akkumulator no necesita cuenta y no hace seguimiento: la única petición de red es la búsqueda de actualizaciones.

## Funciones

- Carga, estado, número de ciclos, temperatura, voltaje, corriente y consumo de la batería del Mac. También el adaptador de corriente, el voltaje de cada celda, las estadísticas de vida útil, el número de serie y la fecha de fabricación.
- Las mismas lecturas para iPhone y iPad conectados por USB o Wi-Fi. Un Apple Watch solo informa de su nivel de carga.
- La carga de accesorios Bluetooth como los AirPods (izquierdo, derecho y estuche), teclados y ratones.
- Una instantánea por dispositivo y día, o cuando pulses el botón. El historial se muestra como gráfico y como tabla ordenable, y se puede exportar a CSV.
- El historial se sincroniza entre tus Mac mediante iCloud.
- Importación desde exportaciones `.ccba` de coconutBattery. Los duplicados se omiten; coconutBattery debe estar instalado.
- Un elemento en la barra de menús si lo quieres, con un icono o la carga actual.
- Una notificación cuando el Mac o un dispositivo iOS baja de un umbral que tú eliges.
- Una vista de datos sin procesar con todos los valores de IORegistry que informa la batería.
- Se actualiza sola.
- Modo claro y oscuro.
- Inglés, alemán, francés, español, italiano, portugués (Portugal y Brasil), chino simplificado, coreano y japonés.

## Instalación

1. Descarga el último `Akkumulator-x.y.z.dmg` desde [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Abre el DMG y arrastra **Akkumulator** a **Aplicaciones**.
3. Ábrela. La app está firmada con un Developer ID y notarizada por Apple, así que macOS no mostrará ningún aviso.

A partir de ahí, Akkumulator se actualiza sola. Para comprobarlo a mano: **Akkumulator › Buscar actualizaciones…**.

### Requisitos

- Un Mac con Apple Silicon (M1 o posterior)
- macOS 15 Sequoia o posterior
- Para iPhone/iPad: desbloquea el dispositivo y toca **Confiar en este ordenador** una vez

## Preguntas frecuentes

**¿Cómo compruebo el estado de la batería de mi iPhone en un Mac?**
Conecta el iPhone con un cable (o en la misma red Wi-Fi después de emparejarlo una vez), desbloquéalo y confía en el Mac. Aparece en la barra lateral, en *Conectado*, con el estado, el número de ciclos y la capacidad.

**¿Puedo importar mi historial de coconutBattery?**
Sí, mediante **Archivo › Importar datos de coconutBattery…**. coconutBattery debe estar instalado en el mismo Mac: sus archivos de exportación están cifrados, y Akkumulator lee la clave de la app instalada en lugar de incluirla. Akkumulator asocia los dispositivos por número de serie, así que las entradas importadas y las nuevas acaban en el mismo historial.

**¿Por qué no está en la Mac App Store?**
Leer los datos de un iPhone o iPad requiere el `MobileDevice.framework` privado de Apple, que las apps de la App Store no pueden usar. Por la misma razón, la app no está en el sandbox.

**¿Envía datos a algún sitio?**
No. Los datos de la batería se quedan en tu Mac (y en tu iCloud, si activas la sincronización). La única petición de red es la búsqueda de actualizaciones en las releases de este repositorio.

## Compilar desde el código fuente

Requiere Xcode 26 o posterior.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

O abre `Akkumulator.xcodeproj` y pulsa Run. Para compilar sin una cuenta de desarrollador de Apple, pon la firma en *Sign to Run Locally* y quita la capacidad de iCloud; la app desactiva la sincronización por sí sola cuando falta el permiso.

### Estructura del proyecto

| Archivo | Función |
|---|---|
| `BatteryInfo.swift` | Modelo de datos y analizador de IORegistry (diseños antiguos y nuevos, incluidos los hijos pack/bank/cell en macOS e iOS 26+) |
| `MacBattery.swift` | Lee `AppleSmartBattery` mediante IOKit |
| `MobileDevice.swift` | Carga `MobileDevice.framework`, detecta dispositivos, consulta `diagnostics_relay` |
| `Accessories.swift` | Lee la carga de los accesorios Bluetooth mediante IOPowerSources |
| `CoconutImport.swift` | Importación `.ccba` |
| `BatteryStore.swift` | Estado en vivo, actualización (Mac cada 10 s, iOS cada 60 s), modelo SwiftData, instantáneas, notificaciones |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | Interfaz |

El historial se guarda en `~/Library/Application Support/Akkumulator/History.store`.

### Releases

`./scripts/release.sh 1.2.0` compila la app, la firma con Developer ID, notariza el DMG, lo firma para Sparkle y publica una release de GitHub con el DMG y `appcast.xml`. Se ejecuta en mi Mac, porque necesita Xcode con sesión iniciada en el equipo, un perfil `notary` creado con `xcrun notarytool store-credentials` y la clave de Sparkle en el llavero de inicio de sesión.

## Contribuir

Los informes de errores, las traducciones y los pull requests son bienvenidos. Para cambios grandes, abre antes un [issue](https://github.com/fwilldev/Akkumulator/issues). Las cadenas están en `Akkumulator/Localizable.xcstrings`; Xcode añade las nuevas al compilar.

## Apoyo

Akkumulator es gratuita y seguirá siéndolo. Si te ha ahorrado una visita al Genius Bar, puedes invitarme a un café en [Ko-fi](https://ko-fi.com/fwilldev).

## Licencia

[MIT](LICENSE). Sin relación con Apple.
