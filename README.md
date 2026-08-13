# Aura Link Native

Cliente iOS nativo em SwiftUI para o Aura Link. O projeto usa componentes Apple, Liquid Glass no iOS 26 e o mesmo Supabase do produto web.

## Gerar o projeto Xcode

```bash
brew install xcodegen
cd AuraLinkNative
xcodegen generate
open AuraLinkNative.xcodeproj
```

## Configuração segura

Use somente a URL do projeto e a **publishable key** do Supabase. Nunca inclua `service_role`, chaves de provedores de IA ou segredos de integrações no app.

Copie `Config/App.example.xcconfig` para `Config/App.xcconfig` e configure os valores. O arquivo real é ignorado pelo Git.

## TestFlight

O workflow `.github/workflows/ios-testflight.yml` valida o projeto no simulador e, quando as credenciais Apple estiverem configuradas, arquiva e envia o build ao App Store Connect.

Consulte `docs/TESTFLIGHT_SETUP.md` para os segredos necessários e o passo de autorização da conta Apple.

