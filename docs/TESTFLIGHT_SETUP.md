# Preparar o TestFlight sem um Mac físico

O build roda em um executor macOS 26 com Xcode 26 no GitHub Actions.

## Requisitos da conta Apple

1. Apple Developer Program ativo.
2. App criado no App Store Connect com Bundle ID `br.com.auralinkai.ios`.
3. Chave da App Store Connect API com acesso de App Manager.
4. Certificado Apple Distribution e provisioning profile App Store para o Bundle ID.

## Secrets do repositório

- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY` — conteúdo do arquivo `.p8`.
- `BUILD_CERTIFICATE_BASE64` — certificado `.p12` em Base64.
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Nenhuma chave `service_role`, OpenAI, Anthropic, Evolution ou Composio deve ser adicionada ao aplicativo.

## Publicação

Execute manualmente o workflow **Aura Link iOS · TestFlight**, marque `upload_to_testflight` e informe um número de build superior ao anterior. O workflow faz testes antes do archive.

