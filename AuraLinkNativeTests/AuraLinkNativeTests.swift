import Testing
@testable import AuraLinkNative

struct AuraLinkNativeTests {
    @Test func demoContentHasCoreDestinations() {
        #expect(DemoData.conversations.count >= 3)
        #expect(DemoData.experts.contains(where: { $0.isActive }))
    }
}

