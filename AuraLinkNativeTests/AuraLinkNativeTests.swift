import Testing
@testable import AuraLinkNative

struct AuraLinkNativeTests {
    @Test func productionAppUsesSecureAuraLinkEndpoint() {
        #expect(AppEnvironment.productionURL.scheme == "https")
        #expect(AppEnvironment.productionURL.host == "www.auralinkai.com.br")
    }

    @Test func nativeShellIdentifiesItsBuildToTheWebApp() {
        #expect(AppEnvironment.nativeUserAgentSuffix.contains("AuraLinkNative"))
    }
}
