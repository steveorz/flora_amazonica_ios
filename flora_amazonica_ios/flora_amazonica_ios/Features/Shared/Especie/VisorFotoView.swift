import SwiftUI
import UIKit

/// CS-07: visor de fotos con zoom (pinch + doble tap), swipe entre fotos
/// y descarga a la fototeca con marca de agua de derechos de autor.
struct VisorFotoView: View {

    let fotos: [Foto]
    @State private var indice: Int
    @State private var descargando = false
    @State private var mensaje: String?
    @Environment(\.dismiss) private var dismiss

    init(fotos: [Foto], initialIndex: Int) {
        self.fotos = fotos
        self._indice = State(initialValue: max(0, min(initialIndex, fotos.count - 1)))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $indice) {
                ForEach(fotos.indices, id: \.self) { i in
                    ZoomableImage(url: fotos[i].url)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack {
                HStack {
                    Button(action: descargar) {
                        if descargando {
                            ProgressView()
                                .tint(.white)
                                .padding(10)
                        } else {
                            Image(systemName: "arrow.down.circle")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(10)
                        }
                    }
                    .background(.black.opacity(0.4), in: Circle())
                    .disabled(descargando)
                    .padding()
                    .accessibilityLabel("Descargar foto")

                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.4), in: Circle())
                    }
                    .padding()
                }
                Spacer()

                if let mensaje {
                    Text(mensaje)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.5), in: Capsule())
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task {
                            try? await Task.sleep(for: .seconds(2.5))
                            withAnimation { self.mensaje = nil }
                        }
                }

                Text(fotos[safe: indice]?.tipo.label ?? "")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.5), in: Capsule())
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Descarga con marca de agua

    private func descargar() {
        guard !descargando, let foto = fotos[safe: indice] else { return }
        descargando = true
        Task {
            do {
                let data: Data
                if let local = foto.localData {
                    data = local
                } else {
                    (data, _) = try await URLSession.shared.data(from: foto.url)
                }
                guard let original = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                let credito = foto.autor.isEmpty ? "FlorAmaz" : foto.autor
                let marcada = Self.conMarcaDeAgua(original, texto: "© \(credito) · FlorAmaz")
                UIImageWriteToSavedPhotosAlbum(marcada, nil, nil, nil)
                withAnimation { mensaje = "Guardada en Fotos con marca de agua" }
            } catch {
                withAnimation { mensaje = "No se pudo descargar la foto" }
            }
            descargando = false
        }
    }

    /// Dibuja el crédito en la esquina inferior derecha, escalado al tamaño de la foto.
    private static func conMarcaDeAgua(_ imagen: UIImage, texto: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: imagen.size)
        return renderer.image { _ in
            imagen.draw(at: .zero)

            let fontSize = max(imagen.size.width, imagen.size.height) * 0.03
            let sombra = NSShadow()
            sombra.shadowColor = UIColor.black.withAlphaComponent(0.7)
            sombra.shadowBlurRadius = fontSize * 0.2
            sombra.shadowOffset = CGSize(width: 0, height: fontSize * 0.05)

            let atributos: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .shadow: sombra
            ]

            let tamano = (texto as NSString).size(withAttributes: atributos)
            let margen = fontSize * 0.7
            let origen = CGPoint(
                x: imagen.size.width - tamano.width - margen,
                y: imagen.size.height - tamano.height - margen
            )
            (texto as NSString).draw(at: origen, withAttributes: atributos)
        }
    }
}

private struct ZoomableImage: View {
    let url: URL

    @State private var scale: CGFloat = 1
    @GestureState private var pinchScale: CGFloat = 1

    var body: some View {
        AsyncImage(url: url) { img in
            img.resizable().scaledToFit()
        } placeholder: {
            ProgressView().tint(.white)
        }
        .scaleEffect(scale * pinchScale)
        .gesture(
            MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    scale = max(1, min(scale * value, 4))
                }
        )
        .onTapGesture(count: 2) {
            withAnimation(.spring) {
                scale = scale > 1 ? 1 : 2
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
