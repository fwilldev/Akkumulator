<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – saúde da bateria do seu Mac, iPhone e iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Última versão"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="Licença MIT"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Apoiar no Ko-fi"></a>
</p>

# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Portugal)](README.pt-PT.md) · **Português (Brasil)** · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

O Akkumulator é um app gratuito e de código aberto para ver a saúde da bateria no macOS. Ele mostra como está a bateria do seu MacBook e a de qualquer iPhone ou iPad que você conectar por cabo ou parear via Wi-Fi: saúde, contagem de ciclos, capacidade, temperatura e muito mais.

## Por que o Akkumulator?

Como ele se compara a outros apps de bateria (em outubro de 2026):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Preço | Grátis | Grátis, Plus pago | Grátis, versão completa $4.99 | Pago | Pago |
| Código aberto | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| Saúde da bateria do iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad via Wi-Fi | ✓ | Plus | ✓ | ✗ | – |
| Acessórios Bluetooth (carga) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Histórico sincronizado via iCloud | ✓ | ✗ | – | – | ✗ |
| Importar histórico do coconutBattery | ✓ | – | – | – | – |
| Dados brutos do medidor | ✓ | Plus | – | – | – |

– = não oferecido ou não documentado. O iStat Menus mostra a carga de acessórios Bluetooth, não a saúde da bateria do iPhone ou do iPad. O Akkumulator não tem conta nem rastreamento: a única requisição de rede é a verificação de atualizações.

## Recursos

- Carga, saúde, contagem de ciclos, temperatura, tensão, corrente e consumo de energia da bateria do seu Mac. Também o adaptador de energia, as tensões de cada célula, estatísticas de vida útil, número de série e data de fabricação.
- As mesmas leituras para iPhones e iPads conectados por USB ou Wi-Fi. Um Apple Watch informa apenas o nível de carga.
- A carga de acessórios Bluetooth como AirPods (esquerdo, direito e estojo), teclados e mouses.
- Um instantâneo por dispositivo por dia, ou sempre que você clicar no botão. O histórico aparece como gráfico e como tabela ordenável, e você pode exportá-lo em CSV.
- O histórico é sincronizado entre os seus Macs pelo iCloud.
- Importação de exportações `.ccba` do coconutBattery. Duplicatas são ignoradas; o coconutBattery precisa estar instalado.
- Um item na barra de menus, se você quiser, com um ícone ou a carga atual.
- Uma notificação quando o Mac ou um dispositivo iOS cair abaixo de um limite que você escolher.
- Uma tela de dados brutos com todos os valores do IORegistry que a bateria informa.
- Atualiza-se sozinho.
- Modo Claro e Escuro.
- Inglês, alemão, francês, espanhol, italiano, português (Portugal e Brasil), chinês simplificado, coreano e japonês.

## Instalação

1. Baixe o `Akkumulator-x.y.z.dmg` mais recente em [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Abra o DMG e arraste o **Akkumulator** para **Aplicativos**.
3. Abra o app. Ele é assinado com um Developer ID e notarizado pela Apple, então o macOS não vai reclamar.

Daí em diante o Akkumulator se atualiza sozinho. Para verificar manualmente, use **Akkumulator › Buscar Atualizações…**.

### Requisitos

- Um Mac com Apple Silicon (M1 ou posterior)
- macOS 15 Sequoia ou posterior
- Para iPhone/iPad: desbloqueie o dispositivo e toque em **Confiar Neste Computador** uma vez

## Perguntas frequentes

**Como vejo a saúde da bateria do meu iPhone no Mac?**
Conecte o iPhone com um cabo (ou na mesma rede Wi-Fi, depois de parear uma vez), desbloqueie-o e confie no Mac. Ele aparece na barra lateral em *Conectado*, com saúde, contagem de ciclos e capacidade.

**Posso importar meu histórico do coconutBattery?**
Sim, em **Arquivo › Importar Dados do coconutBattery…**. O coconutBattery precisa estar instalado no mesmo Mac: os arquivos de exportação são criptografados, e o Akkumulator lê a chave do app instalado em vez de embuti-la. O Akkumulator associa os dispositivos pelo número de série, então as entradas importadas e as novas ficam no mesmo histórico.

**Por que não está na Mac App Store?**
Ler os dados do iPhone e do iPad exige o `MobileDevice.framework` privado da Apple, que apps da App Store não podem usar. Pelo mesmo motivo, o app não roda em sandbox.

**Ele envia dados para algum lugar?**
Não. Os dados da bateria ficam no seu Mac (e no seu iCloud, se você ativar a sincronização). A única requisição de rede é a verificação de atualizações nas versões deste repositório.

## Compilando a partir do código-fonte

Requer o Xcode 26 ou posterior.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Ou abra o `Akkumulator.xcodeproj` e clique em Run. Para compilar sem uma conta de desenvolvedor da Apple, defina a assinatura como *Sign to Run Locally* e remova a capacidade do iCloud; o app desativa a sincronização sozinho quando falta o entitlement.

### Estrutura do projeto

| Arquivo | Função |
|---|---|
| `BatteryInfo.swift` | Modelo de dados e parser do IORegistry (layouts antigos e novos, incluindo os filhos pack/bank/cell no macOS e iOS 26+) |
| `MacBattery.swift` | Lê `AppleSmartBattery` via IOKit |
| `MobileDevice.swift` | Carrega o `MobileDevice.framework`, detecta dispositivos, consulta o `diagnostics_relay` |
| `Accessories.swift` | Lê a carga dos acessórios Bluetooth via IOPowerSources |
| `CoconutImport.swift` | Importação `.ccba` |
| `BatteryStore.swift` | Estado ao vivo, atualização (Mac a cada 10 s, iOS a cada 60 s), modelo SwiftData, instantâneos, notificações |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | Interface |

O histórico é salvo em `~/Library/Application Support/Akkumulator/History.store`.

### Releases

`./scripts/release.sh 1.2.0` compila o app, assina com Developer ID, notariza o DMG, assina para o Sparkle e publica um release no GitHub com o DMG e o `appcast.xml`. Ele roda no meu Mac, porque precisa do Xcode logado na equipe, de um perfil `notary` criado com `xcrun notarytool store-credentials` e da chave do Sparkle no keychain de login.

## Contribuindo

Relatos de bugs, traduções e pull requests são bem-vindos. Abra antes uma [issue](https://github.com/fwilldev/Akkumulator/issues) para mudanças maiores. As strings ficam em `Akkumulator/Localizable.xcstrings`; o Xcode adiciona as novas na hora da compilação.

## Apoio

O Akkumulator é gratuito e vai continuar assim. Se ele te poupou uma ida à Genius Bar, você pode me pagar um café no [Ko-fi](https://ko-fi.com/fwilldev).

## Licença

[MIT](LICENSE). Sem afiliação com a Apple.
