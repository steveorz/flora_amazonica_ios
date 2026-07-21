import SwiftUI

/// CS-06: galería completa de fotos de una especie.
struct GaleriaFotosView: View {

    let especie: Especie
    @State private var visor: Foto?

    private let cols = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(especie.fotos) { foto in
                    Button { visor = foto } label: {
                        AsyncImage(url: foto.url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color(.systemGray5))
                                .overlay(ProgressView())
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Galería")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $visor) { foto in
            VisorFotoView(
                fotos: especie.fotos,
                initialIndex: especie.fotos.firstIndex(of: foto) ?? 0
            )
        }
    }
}
