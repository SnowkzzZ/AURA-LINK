import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        ZStack {
            AuraBackground()
            switch session.state {
            case .loading:
                VStack(spacing: 16) {
                    AuraOrb(size: 56)
                    ProgressView("Preparando a Aura")
                }
            case .signedOut:
                LoginView()
            case .signedIn, .demo:
                MainTabView()
            }
        }
        .animation(.smooth(duration: 0.45), value: session.state)
    }
}

