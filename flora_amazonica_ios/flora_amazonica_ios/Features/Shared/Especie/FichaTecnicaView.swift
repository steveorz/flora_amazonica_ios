import SwiftUI
import UIKit
import CoreImage

/// CS-05: ficha técnica pública de una especie.
///
/// Estilo Apple Music / News+: la foto principal se duplica como fondo
/// full-screen desenfocado. La copia clara arriba se enmascara con un
/// gradient lineal en el borde inferior para revelar el fondo (que es
/// la misma foto difuminada). Como ambas capas son la misma imagen
/// alineadas, el resultado es una sola pantalla unificada sin que se
/// note una "encima de la otra".
struct FichaTecnicaView: View {

    let especie: Especie

    @Environment(FavoritosStore.self) private var favoritos
    @State private var tab: FichaTab = .general
    @State private var visorAbierto: Foto?

    // Colores adaptativos SOLO para los textos del bloque de info
    // (familia, título, científico, metadatos). Se calculan a partir
    // de la luminancia del color promedio de la foto del hero.
    @State private var infoPrimary: Color = .primary
    @State private var infoSecondary: Color = .secondary

    enum FichaTab: String, CaseIterable, Hashable {
        case general, morfologia, ecologia, usos, mapa, galeria

        var label: String {
            switch self {
            case .general:    return "General"
            case .morfologia: return "Morfología"
            case .ecologia:   return "Ecología"
            case .usos:       return "Usos"
            case .mapa:       return "Mapa"
            case .galeria:    return "Galería"
            }
        }
    }

    private var heroFoto: Foto? {
        especie.fotos.first(where: { $0.tipo == .plantaCompleta }) ?? especie.fotos.first
    }

    var body: some View {
        ZStack {
            // Capa 1: la misma foto, full-screen, fuertemente desenfocada.
            // Es la base de color de TODA la pantalla.
            ambientBackground
                .ignoresSafeArea()

            // Capa 2: ScrollView con la foto clara arriba (enmascarada para
            // fundirse con la capa 1) y el contenido debajo.
            ScrollView {
                VStack(spacing: 0) {
                    heroImage
                    contentStack
                }
            }
            .scrollIndicators(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)
            .ignoresSafeArea(edges: .top)
        }
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    favoritos.toggle(especie.id)
                } label: {
                    Image(systemName: favoritos.isFavorite(especie.id) ? "heart.fill" : "heart")
                        .foregroundStyle(favoritos.isFavorite(especie.id) ? .red : .primary)
                }

                ShareLink(item: "\(especie.nombreCientifico) — \(especie.nombreLocal) (\(especie.codigoSeguimiento))") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .fullScreenCover(item: $visorAbierto) { foto in
            VisorFotoView(
                fotos: especie.fotos,
                initialIndex: especie.fotos.firstIndex(of: foto) ?? 0
            )
        }
        .task(id: heroFoto?.url) {
            await detectInfoColors()
        }
    }

    /// Descarga la imagen, samplea SOLO la mitad inferior (que es la zona
    /// que termina detrás del texto del bloque info después del blur y
    /// el gradient mask), calcula luminancia relativa W3C y elige un
    /// color de texto que sea un tono muy claro o muy oscuro del MISMO
    /// tinte del fondo — contrasta lo necesario para ser legible pero
    /// conserva la armonía cromática con la foto.
    private func detectInfoColors() async {
        guard let url = heroFoto?.url else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data),
                  let avg = uiImage.averageColorBottomHalf else { return }

            // Luminancia relativa W3C (sRGB linearizado).
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            avg.getRed(&r, green: &g, blue: &b, alpha: &a)
            func linearize(_ c: CGFloat) -> CGFloat {
                c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
            }
            let luminance = 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)

            // Hue y saturación del fondo para conservar el tinte.
            var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0
            avg.getHue(&h, saturation: &s, brightness: &br, alpha: &a)

            let newPrimary: Color
            if luminance < 0.5 {
                // Fondo oscuro → casi blanco, leve tinte del hue.
                newPrimary = Color(UIColor(
                    hue: h,
                    saturation: min(s * 0.25, 0.10),
                    brightness: 0.98,
                    alpha: 1
                ))
            } else {
                // Fondo claro → casi negro, leve tinte del hue.
                newPrimary = Color(UIColor(
                    hue: h,
                    saturation: min(s * 0.35, 0.20),
                    brightness: 0.12,
                    alpha: 1
                ))
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.25)) {
                    infoPrimary = newPrimary
                    infoSecondary = newPrimary.opacity(0.72)
                }
            }
        } catch {
            // Silencioso: quedan los colores por defecto.
        }
    }

    private var displayTitle: String {
        especie.nombreLocal.isEmpty ? especie.nombreCientifico : especie.nombreLocal
    }

    // MARK: - Hero (foto clara con mask gradient abajo)

    private var heroImage: some View {
        Group {
            if let foto = heroFoto {
                Button {
                    visorAbierto = foto
                } label: {
                    GeometryReader { proxy in
                        AsyncImage(url: foto.url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(especie.habito.color.opacity(0.4))
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    }
                    // Altura amplia para que la foto bleed detrás del nav bar
                    // y el status bar. El Liquid Glass de los botones (back,
                    // heart, share) difumina naturalmente la parte superior.
                    .frame(height: 540)
                    // Máscara: arriba 100% opaco (foto detrás del nav bar
                    // intacta), abajo se funde con el ambient.
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.0),
                                .init(color: .black, location: 0.70),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Fondo ambiental — la misma foto, full screen, blur fuerte

    private var ambientBackground: some View {
        GeometryReader { proxy in
            ZStack {
                // Base de color de hábito (solo se ve si no hay foto).
                especie.habito.color.opacity(0.55)

                // Foto difuminada que toma colores reales.
                if let foto = heroFoto {
                    AsyncImage(url: foto.url) { phase in
                        if let img = phase.image {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .blur(radius: 80, opaque: true)
                                .saturation(1.6)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Contenido bajo la foto

    private var contentStack: some View {
        VStack(spacing: 0) {
            infoSection
                .padding(.top, 8)
                .padding(.horizontal, 22)
            tabPicker
                .padding(.top, 26)
            tabContent
                .padding(.top, 14)
                .padding(.horizontal, 16)
                .padding(.bottom, 60)
        }
    }

    private var infoSection: some View {
        VStack(spacing: 10) {
            Text(especie.familia)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(infoSecondary)

            Text(displayTitle)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(infoPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(infoSecondary)
                Text("\(especie.nombreCientifico) \(especie.autorNombre)".trimmingCharacters(in: .whitespaces))
                    .font(.subheadline.italic())
                    .foregroundStyle(infoSecondary)
                    .multilineTextAlignment(.center)
            }

            metadataRow
                .padding(.top, 10)
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 0) {
            metaCell(label: "HÁBITO", value: especie.habito.label)
            metaDivider
            metaCell(label: "ALTITUD", value: "\(Int(especie.ubicacion.altitud)) m")
            metaDivider
            metaCell(label: "VIDA", value: especie.tipoVida.label)
        }
    }

    private func metaCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(infoSecondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(infoPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var metaDivider: some View {
        Rectangle()
            .fill(infoPrimary.opacity(0.25))
            .frame(width: 1, height: 32)
    }

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FichaTab.allCases, id: \.self) { t in
                    Button { tab = t } label: {
                        Text(t.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(tab == t ? Color.onBrand : Color.primary)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(tab == t ? AnyShapeStyle(Color.brand) : AnyShapeStyle(.ultraThinMaterial))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .general:    GeneralTab(especie: especie)
        case .morfologia: MorfologiaTab(especie: especie)
        case .ecologia:   EcologiaTab(especie: especie)
        case .usos:       UsosTab()
        case .mapa:       MapaTab(especie: especie)
        case .galeria:    GaleriaTab(especie: especie, onFoto: { visorAbierto = $0 })
        }
    }
}

// MARK: - Tabs

private struct GeneralTab: View {
    let especie: Especie
    var body: some View {
        glassSection(titulo: "Descripción") {
            Text(especie.descripcion.isEmpty ? "Sin descripción." : especie.descripcion)
                .font(.subheadline)
        }
    }
}

private struct MorfologiaTab: View {
    let especie: Especie
    var body: some View {
        VStack(spacing: 12) {
            if let d = especie.datosDasometricos {
                glassSection(titulo: "Datos dasométricos") {
                    VStack(alignment: .leading, spacing: 6) {
                        fila("Altura",     "\(Dasometria.formato(d.altura)) m")
                        fila("CAP",        "\(Dasometria.formato(d.cap)) cm")
                        fila("DAP",        "\(Dasometria.formato(d.dap)) cm")
                        fila("Diám. copa", "\(Dasometria.formato(d.diamCopaParalelo)) × \(Dasometria.formato(d.diamCopaPerpendicular)) m")
                    }
                }
            }
            if !especie.caracteres.isEmpty {
                glassSection(titulo: "Caracteres") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(especie.caracteres.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(k.capitalized)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text(v).font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct EcologiaTab: View {
    let especie: Especie
    var body: some View {
        glassSection(titulo: "Hábitat y distribución") {
            VStack(alignment: .leading, spacing: 6) {
                fila("Hábitat",      especie.ubicacion.tipoHabitat)
                fila("Altitud",      "\(Int(especie.ubicacion.altitud)) m")
                fila("Tipo de vida", especie.tipoVida.label)
                fila("Distribución", especie.distribucionPaises.joined(separator: ", "))
            }
        }
    }
}

private struct UsosTab: View {
    var body: some View {
        glassSection(titulo: "Usos") {
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                Text("Información de usos no disponible para esta especie.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MapaTab: View {
    let especie: Especie
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MapaDistribucionView(especie: especie)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            NavigationLink {
                MapaDistribucionView(especie: especie, fullScreen: true)
                    .navigationTitle("Distribución")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Label("Ver mapa completo", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

private struct GaleriaTab: View {
    let especie: Especie
    var onFoto: (Foto) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(especie.fotos) { foto in
                        Button { onFoto(foto) } label: {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: foto.url) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(.ultraThinMaterial)
                                }
                                .frame(width: 140, height: 140)
                                .clipped()
                                
                                Text(foto.tipo.rawValue.capitalized)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.6), in: Capsule())
                                    .padding(6)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            NavigationLink {
                GaleriaFotosView(especie: especie)
            } label: {
                Label("Ver galería completa", systemImage: "photo.on.rectangle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

// MARK: - Helpers compartidos

@ViewBuilder
private func glassSection<Content: View>(titulo: String, @ViewBuilder content: @escaping () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(titulo).font(.headline)
        content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
}

private func fila(_ label: String, _ value: String) -> some View {
    HStack(alignment: .top) {
        Text(label).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
        Spacer()
        Text(value).multilineTextAlignment(.trailing)
    }
    .font(.subheadline)
}

// MARK: - UIImage: color promedio (CIAreaAverage)

fileprivate extension UIImage {
    /// Reduce la imagen a un único píxel con `CIAreaAverage` para
    /// obtener el color promedio.
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        return averageColor(ciImage: inputImage, extent: inputImage.extent)
    }

    /// Promedio solo de la MITAD INFERIOR de la imagen (lo que queda
    /// detrás del bloque de texto info en la pantalla). En CIImage el
    /// origen es bottom-left, así que la mitad VISUAL inferior tiene
    /// y entre 0 y height/2.
    var averageColorBottomHalf: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let full = inputImage.extent
        let bottomHalf = CGRect(
            x: full.origin.x,
            y: full.origin.y,
            width: full.size.width,
            height: full.size.height / 2
        )
        return averageColor(ciImage: inputImage, extent: bottomHalf)
    }

    private func averageColor(ciImage: CIImage, extent: CGRect) -> UIColor? {
        let extentVector = CIVector(
            x: extent.origin.x,
            y: extent.origin.y,
            z: extent.size.width,
            w: extent.size.height
        )
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]
        ) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}
