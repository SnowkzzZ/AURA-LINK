import SwiftUI

struct ChatView: View {
    let title: String
    var initialPrompt = ""
    @State private var input = ""
    @State private var messages: [AuraMessage] = []

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(messages) { message in
                        HStack(alignment: .top, spacing: 10) {
                            if message.role == .assistant { AuraOrb(size: 28) }
                            Text(message.text)
                                .padding(13)
                                .background(message.role == .user ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear), in: RoundedRectangle(cornerRadius: 18))
                            if message.role == .assistant { Spacer(minLength: 30) }
                        }
                        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
                        .id(message.id)
                    }
                }.padding(18).padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 10) {
                    Button {} label: { Image(systemName: "plus") }
                    TextField("Mensagem para a Aura", text: $input, axis: .vertical).lineLimit(1...5)
                    Button { send() } label: { Image(systemName: "arrow.up") }
                        .buttonStyle(.borderedProminent).tint(.primary).disabled(input.isEmpty)
                }
                .padding(10).auraGlass(cornerRadius: 26).padding(.horizontal, 14)
            }
            .onChange(of: messages.count) { _, _ in if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } } }
        }
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard messages.isEmpty else { return }
            messages = initialPrompt.isEmpty
                ? [.init(role: .assistant, text: "Olá! Estou pronta para pensar, criar e executar com você.")]
                : [.init(role: .user, text: initialPrompt), .init(role: .assistant, text: "Entendi. Vou organizar o melhor caminho e preservar todo o contexto que você trouxe.")]
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.init(role: .user, text: text)); input = ""
        withAnimation(.smooth) { messages.append(.init(role: .assistant, text: "Recebi sua mensagem. Na próxima etapa, esta conversa será conectada ao mesmo fluxo de IA do Aura Link web.")) }
    }
}

struct ConversationsView: View {
    var body: some View {
        NavigationStack {
            List(DemoData.conversations) { item in NavigationLink(value: item) { ConversationRow(item: item) }.listRowBackground(Color.clear) }
                .listStyle(.plain).navigationTitle("Chats").searchable(text: .constant(""), prompt: "Pesquisar chats")
                .navigationDestination(for: AuraConversation.self) { ChatView(title: $0.title) }
                .toolbar { Button("Novo", systemImage: "square.and.pencil") {} }
        }
    }
}

