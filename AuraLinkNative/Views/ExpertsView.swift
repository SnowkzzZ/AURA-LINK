import SwiftUI

struct ExpertsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(DemoData.experts) { expert in
                        HStack(spacing: 14) {
                            Image(systemName: expert.symbol).font(.title3).frame(width: 46, height: 46).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                            VStack(alignment: .leading, spacing: 4) { Text(expert.name).font(.headline); Text(expert.role).font(.caption).foregroundStyle(.secondary); Text("\(expert.runs) execuções").font(.caption2).foregroundStyle(.tertiary) }
                            Spacer()
                            Circle().fill(expert.isActive ? .green : .secondary.opacity(0.35)).frame(width: 9, height: 9)
                            Menu { Button("Executar agora", systemImage: "play.fill") {}; Button("Editar", systemImage: "slider.horizontal.3") {} } label: { Image(systemName: "ellipsis") }
                        }.padding(16).auraGlass(cornerRadius: 22)
                    }
                }.padding(20)
            }.navigationTitle("Experts").toolbar { Button("Criar", systemImage: "plus") {} }
        }
    }
}

struct SearchView: View {
    @State private var query = ""
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Busque em toda a Aura", systemImage: "sparkle.magnifyingglass", description: Text("Encontre chats, imagens, memórias e Experts em um só lugar."))
                .navigationTitle("Buscar").searchable(text: $query, prompt: "O que você procura?")
        }
    }
}

