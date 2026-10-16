<p align="center">
  <img src=".github/assets/header.png" alt="Akkumulator – estado da bateria do seu Mac, iPhone e iPad" width="100%">
</p>

<p align="center">
  <a href="https://github.com/fwilldev/Akkumulator/releases/latest"><img src="https://img.shields.io/github/v/release/fwilldev/Akkumulator?label=download&color=0a2a8a" alt="Última versão"></a>
  <img src="https://img.shields.io/badge/macOS-15%2B-0a2a8a?logo=apple" alt="macOS 15+">
  <img src="https://img.shields.io/badge/Apple%20Silicon-arm64-0a2a8a" alt="Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fwilldev/Akkumulator?color=0a2a8a" alt="Licença MIT"></a>
  <a href="https://ko-fi.com/fwilldev"><img src="https://img.shields.io/badge/Ko--fi-support-ff5e5b?logo=ko-fi&logoColor=white" alt="Apoiar no Ko-fi"></a>
</p>

# Akkumulator

[English](README.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · **Português (Portugal)** · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [日本語](README.ja.md)

O Akkumulator é uma aplicação gratuita e de código aberto para ver o estado da bateria no macOS. Diz-lhe como está a bateria do seu MacBook e a de qualquer iPhone ou iPad que ligue por cabo ou emparelhe por Wi-Fi: estado, número de ciclos, capacidade, temperatura e bastante mais.

## Porquê o Akkumulator?

Como se compara com outras aplicações de bateria (em outubro de 2026):

| | Akkumulator | [coconutBattery](https://www.coconut-flavour.com/coconutbattery/) | [Mac 4 Breakfast](https://github.com/onekapisch/Mac-4-Breakfast) | [iStat Menus](https://bjango.com/mac/istatmenus/) | [Juicy](https://getjuicy.app) |
|---|:-:|:-:|:-:|:-:|:-:|
| Preço | Grátis | Grátis, Plus pago | Grátis, versão completa $4.99 | Pago | Pago |
| Código aberto | ✓ (MIT) | ✗ | ✗ | ✗ | ✗ |
| Estado da bateria do iPhone/iPad | ✓ | ✓ | ✓ | ✗ | ✓ |
| iPhone/iPad por Wi-Fi | ✓ | Plus | ✓ | ✗ | – |
| Acessórios Bluetooth (carga) | ✓ | ✗ | ✓ | ✓ | ✓ |
| Histórico sincronizado via iCloud | ✓ | ✗ | – | – | ✗ |
| Importar histórico do coconutBattery | ✓ | – | – | – | – |
| Dados em bruto do medidor | ✓ | Plus | – | – | – |

– = não disponível ou não documentado. O iStat Menus mostra a carga dos acessórios Bluetooth, não o estado da bateria do iPhone ou do iPad. O Akkumulator não tem conta nem rastreio: o único pedido de rede é a procura de atualizações.

## Funcionalidades

- Carga, estado, número de ciclos, temperatura, tensão, corrente e consumo de energia da bateria do seu Mac. Também o transformador, as tensões de cada célula, estatísticas de vida útil, número de série e data de fabrico.
- As mesmas leituras para iPhones e iPads ligados por USB ou Wi-Fi. Um Apple Watch só indica o nível de carga.
- A carga de acessórios Bluetooth como AirPods (esquerdo, direito e estojo), teclados e ratos.
- Um instantâneo por dispositivo e por dia, ou sempre que clicar no botão. O histórico aparece como gráfico e como tabela ordenável, e pode exportá-lo em CSV.
- O histórico sincroniza entre os seus Macs através do iCloud.
- Importação de exportações `.ccba` do coconutBattery. Os duplicados são ignorados; o coconutBattery tem de estar instalado.
- Um item na barra de menus, se quiser, com um ícone ou a carga atual.
- Uma notificação quando o Mac ou um dispositivo iOS fica abaixo de um limite que escolher.
- Uma vista de dados em bruto com todos os valores do IORegistry que a bateria comunica.
- Atualiza-se sozinho.
- Modo claro e escuro.
- Inglês, alemão, francês, espanhol, italiano, português (Portugal e Brasil), chinês simplificado, coreano e japonês.

## Instalação

1. Transfira o `Akkumulator-x.y.z.dmg` mais recente em [Releases](https://github.com/fwilldev/Akkumulator/releases/latest).
2. Abra o DMG e arraste o **Akkumulator** para **Aplicações**.
3. Abra-o. A aplicação está assinada com um Developer ID e notarizada pela Apple, por isso o macOS não vai queixar-se.

A partir daí, o Akkumulator atualiza-se sozinho. Para procurar manualmente, use **Akkumulator › Procurar atualizações…**.

### Requisitos

- Um Mac com Apple Silicon (M1 ou posterior)
- macOS 15 Sequoia ou posterior
- Para iPhone/iPad: desbloqueie o dispositivo e toque em **Confiar neste computador** uma vez

## Perguntas frequentes

**Como vejo o estado da bateria do meu iPhone num Mac?**
Ligue o iPhone com um cabo (ou na mesma rede Wi-Fi, depois de o emparelhar uma vez), desbloqueie-o e confie no Mac. Aparece na barra lateral em *Ligado*, com estado, número de ciclos e capacidade.

**Posso importar o meu histórico do coconutBattery?**
Sim, através de **Ficheiro › Importar dados do coconutBattery…**. O coconutBattery tem de estar instalado no mesmo Mac: os ficheiros de exportação são cifrados e o Akkumulator lê a chave da aplicação instalada em vez de a incluir. O Akkumulator associa os dispositivos pelo número de série, por isso as entradas importadas e as novas ficam no mesmo histórico.

**Porque não está na Mac App Store?**
Ler os dados do iPhone e do iPad exige o `MobileDevice.framework` privado da Apple, que as aplicações da App Store não podem usar. Pelo mesmo motivo, a aplicação não está em sandbox.

**Envia dados para algum lado?**
Não. Os dados da bateria ficam no seu Mac (e no seu iCloud, se ativar a sincronização). O único pedido de rede é a procura de atualizações nas versões deste repositório.

## Compilar a partir do código-fonte

Requer o Xcode 26 ou posterior.

```sh
git clone https://github.com/fwilldev/Akkumulator.git
cd Akkumulator
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates build
xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -derivedDataPath build -allowProvisioningUpdates test
```

Ou abra `Akkumulator.xcodeproj` e prima Run. Para compilar sem uma conta de programador Apple, defina a assinatura como *Sign to Run Locally* e remova a capacidade do iCloud; a aplicação desativa a sincronização sozinha quando falta o entitlement.

### Estrutura do projeto

| Ficheiro | Função |
|---|---|
| `BatteryInfo.swift` | Modelo de dados e parser do IORegistry (estruturas antigas e novas, incluindo os filhos pack/bank/cell no macOS e iOS 26+) |
| `MacBattery.swift` | Lê `AppleSmartBattery` através do IOKit |
| `MobileDevice.swift` | Carrega o `MobileDevice.framework`, deteta dispositivos, consulta o `diagnostics_relay` |
| `Accessories.swift` | Lê a carga dos acessórios Bluetooth através de IOPowerSources |
| `CoconutImport.swift` | Importação `.ccba` |
| `BatteryStore.swift` | Estado em direto, atualização (Mac a cada 10 s, iOS a cada 60 s), modelo SwiftData, instantâneos, notificações |
| `ContentView.swift`, `HistoryView.swift`, `MenuBarView.swift` | Interface |

O histórico é guardado em `~/Library/Application Support/Akkumulator/History.store`.

### Versões

`./scripts/release.sh 1.2.0 notes.md` compila a aplicação, assina-a com Developer ID, notariza o DMG, assina-o para o Sparkle e publica uma versão no GitHub com o DMG e o `appcast.xml`. Corre no meu Mac, porque precisa do Xcode com sessão iniciada na equipa, de um perfil `notary` criado com `xcrun notarytool store-credentials` e da chave do Sparkle no keychain de início de sessão.

## Contribuir

Relatórios de erros, traduções e pull requests são bem-vindos. Abra primeiro uma [issue](https://github.com/fwilldev/Akkumulator/issues) para alterações maiores. As cadeias de texto estão em `Akkumulator/Localizable.xcstrings`; o Xcode adiciona as novas durante a compilação.

## Apoio

O Akkumulator é gratuito e vai continuar a ser. Se lhe poupou uma ida à Genius Bar, pode pagar-me um café no [Ko-fi](https://ko-fi.com/fwilldev).

## Licença

[MIT](LICENSE). Sem afiliação com a Apple.
