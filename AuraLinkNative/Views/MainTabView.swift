import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Início", systemImage: "sparkles", value: 0) { HomeView() }
            Tab("Chats", systemImage: "bubble.left.and.bubble.right", value: 1) { ConversationsView() }
            Tab("Imagens", systemImage: "photo.on.rectangle.angled", value: 2) { ImagesView() }
            Tab("Experts", systemImage: "brain.head.profile", value: 3) { ExpertsView() }
            Tab("Buscar", systemImage: "magnifyingglass", value: 4, role: .search) { SearchView() }
        }
        .tint(AuraTheme.electricBlue)
    }
}

