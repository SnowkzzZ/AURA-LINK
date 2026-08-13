import Foundation

struct AuraConversation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let preview: String
    let updatedAt: String
    let symbol: String
}

struct AuraMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
}

struct AuraExpert: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String
    let symbol: String
    let isActive: Bool
    let runs: Int
}

enum DemoData {
    static let conversations = [
        AuraConversation(title: "Planejamento da campanha", preview: "Estruture a próxima semana comercial...", updatedAt: "Agora", symbol: "sparkles"),
        AuraConversation(title: "Identidade visual", preview: "Analise o material da Atlântica...", updatedAt: "Ontem", symbol: "paintpalette"),
        AuraConversation(title: "Resumo de vendas", preview: "Cruze os dados da planilha...", updatedAt: "Seg", symbol: "chart.line.uptrend.xyaxis")
    ]

    static let experts = [
        AuraExpert(name: "Sofia", role: "Consultora comercial", symbol: "person.crop.circle.badge.checkmark", isActive: true, runs: 184),
        AuraExpert(name: "Radar diário", role: "Inteligência comercial", symbol: "scope", isActive: true, runs: 52),
        AuraExpert(name: "Lia", role: "Suporte ao cliente", symbol: "headphones", isActive: false, runs: 27)
    ]
}
