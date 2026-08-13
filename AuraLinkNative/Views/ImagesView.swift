import SwiftUI

struct ImagesView: View {
    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 12)]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Crie com o Studio").font(.title2.bold())
                        Text("Descreva uma cena ou use uma imagem de referência.").font(.subheadline).foregroundStyle(.secondary)
                        Button("Criar nova imagem", systemImage: "wand.and.stars") {}
                            .buttonStyle(.borderedProminent).tint(.primary).padding(.top, 4)
                    }.padding(20).auraGlass(cornerRadius: 26)

                    Text("Sua galeria").font(.headline)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...8, id: \.self) { index in
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 22).fill([AuraTheme.electricBlue, AuraTheme.iris, AuraTheme.cyan][index % 3].gradient).aspectRatio(index % 3 == 0 ? 1.0 : 0.82, contentMode: .fit)
                                VStack(alignment: .leading) { Image(systemName: index % 2 == 0 ? "photo.artframe" : "camera.aperture").font(.title); Text(index % 2 == 0 ? "Campanha visual" : "Retrato editorial").font(.caption.bold()) }.foregroundStyle(.white).padding(14)
                            }
                        }
                    }
                }.padding(20)
            }.navigationTitle("Imagens")
        }
    }
}

