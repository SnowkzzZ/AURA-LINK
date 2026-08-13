import SwiftUI

@main
struct AuraLinkNativeApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .task { await session.restore() }
                .onOpenURL { url in
                    Task { await session.handle(url: url) }
                }
        }
    }
}

