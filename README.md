# Aura Link para iOS

Aplicativo iOS do Aura Link com uma camada nativa SwiftUI sobre o produto em produção. Essa arquitetura mantém todas as áreas, conversas e integrações sincronizadas com a versão web, enquanto o iPhone fornece Liquid Glass, gestos, feedback tátil, sessão persistente, áudio em modo de voz, câmera, microfone e anexos.

## Gerar o projeto Xcode

```bash
brew install xcodegen
xcodegen generate
open AuraLinkNative.xcodeproj
```

## Segurança

O aplicativo não incorpora chaves privadas nem replica a autenticação. Login, autorização, dados e integrações continuam no ambiente oficial `https://www.auralinkai.com.br`, com os cookies isolados e persistidos pelo armazenamento seguro do WebKit.

## TestFlight

O workflow `.github/workflows/ios-testflight.yml` valida o projeto no simulador, assina o aplicativo e envia o build ao App Store Connect.
