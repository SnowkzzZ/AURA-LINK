import SwiftUI

struct HomeView: View {
    @State private var prompt = ""
    @State private var showingChat = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Bom dia, Juliano").font(.subheadline).foregroundStyle(.secondary)
                        Text("O que vamos\ncriar hoje?")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .tracking(-1.5)
                    }

                    VStack(spacing: 12) {
                        TextField("Pergunte qualquer coisa à Aura", text: $prompt, axis: .vertical)
                            .lineLimit(2...6)
                            .font(.body)
                        HStack {
                            Menu {
                                Button("Adicionar foto", systemImage: "photo") {}
                                Button("Adicionar arquivo", systemImage: "doc") {}
                            } label: { Image(systemName: "plus") }
                            Spacer()
                            Button { showingChat = true } label: { Image(systemName: "arrow.up") }
                                .buttonStyle(.borderedProminent).tint(.primary)
                                .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(18)
                    .auraGlass(cornerRadius: 28)

                    SectionHeader(title: "Continue de onde parou", action: "Ver todos")
                    ForEach(DemoData.conversations.prefix(2)) { item in
                        NavigationLink(value: item) { ConversationRow(item: item) }
                            .buttonStyle(.plain)
                    }

                    SectionHeader(title: "Atalhos", action: nil)
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                        QuickAction(title: "Criar imagem", subtitle: "Studio", symbol: "wand.and.stars")
                        QuickAction(title: "Usar um Expert", subtitle: "Automação", symbol: "brain.head.profile")
                        QuickAction(title: "Falar com Aura", subtitle: "Voz", symbol: "waveform")
                        QuickAction(title: "Integrações", subtitle: "1.062 apps", symbol: "point.3.connected.trianglepath.dotted")
                    }
                }
                .padding(20)
            }
            .navigationTitle("Aura Link")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { AuraOrb(size: 30) }
                ToolbarItem(placement: .topBarTrailing) { Button("Novo", systemImage: "square.and.pencil") {} }
            }
            .navigationDestination(for: AuraConversation.self) { ChatView(title: $0.title) }
            .navigationDestination(isPresented: $showingChat) { ChatView(title: "Novo chat", initialPrompt: prompt) }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let action: String?
    var body: some View {
        HStack { Text(title).font(.headline); Spacer(); if let action { Button(action) {}.font(.caption) } }
    }
}

struct ConversationRow: View {
    let item: AuraConversation
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.symbol).frame(width: 42, height: 42).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.subheadline.weight(.semibold))
                Text(item.preview).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Text(item.updatedAt).font(.caption2).foregroundStyle(.tertiary)
        }
        .padding(14)
        .auraGlass(cornerRadius: 20)
    }
}

struct QuickAction: View {
    let title: String
    let subtitle: String
    let symbol: String
    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: symbol).font(.title3)
                VStack(alignment: .leading, spacing: 2) { Text(title).font(.subheadline.weight(.semibold)); Text(subtitle).font(.caption2).foregroundStyle(.secondary) }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        }
        .buttonStyle(.plain).auraGlass(cornerRadius: 20)
    }
}

