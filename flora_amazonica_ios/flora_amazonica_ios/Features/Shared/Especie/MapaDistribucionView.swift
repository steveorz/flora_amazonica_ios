import SwiftUI
import MapKit

/// CS-08: mapa de distribución de una especie. Marcadores de avistamientos mock.
struct MapaDistribucionView: View {

    let especie: Especie
    var fullScreen: Bool = false

    @State private var seleccionado: Avistamiento?

    private struct Avistamiento: Identifiable, Hashable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let codigo: String
        let fecha: Date
        let principal: Bool

        static func == (l: Avistamiento, r: Avistamiento) -> Bool { l.id == r.id }
        func hash(into h: inout Hasher) { h.combine(id) }
    }

    private var avistamientos: [Avistamiento] {
        let base = especie.ubicacion
        // El avistamiento principal es el del registro; añadimos algunos
        // adicionales determinísticos en Loreto para visualizar distribución.
        let principal = Avistamiento(
            id: "\(especie.id)-0",
            coordinate: CLLocationCoordinate2D(latitude: base.lat, longitude: base.long),
            codigo: especie.codigoSeguimiento,
            fecha: especie.fechaEnvio,
            principal: true
        )
        let extras = [
            (0.12, -0.08, -90),
            (-0.07, 0.11, -150),
            (0.18, 0.04, -45)
        ].enumerated().map { idx, off in
            Avistamiento(
                id: "\(especie.id)-\(idx + 1)",
                coordinate: CLLocationCoordinate2D(
                    latitude: base.lat + off.0,
                    longitude: base.long + off.1
                ),
                codigo: "FAM-2026-99\(String(format: "%03d", (idx + 1) * 17))",
                fecha: Date().addingTimeInterval(Double(off.2) * 86_400),
                principal: false
            )
        }
        return [principal] + extras
    }

    private var initialPosition: MapCameraPosition {
        let centro = especie.ubicacion
        return .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centro.lat, longitude: centro.long),
            span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(initialPosition: initialPosition) {
                ForEach(avistamientos) { av in
                    Annotation(av.codigo, coordinate: av.coordinate) {
                        Button { seleccionado = av } label: {
                            Image(systemName: av.principal ? "leaf.fill" : "leaf")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.onBrand)
                                .padding(8)
                                .background(av.principal ? Color.brand : Color.brand.opacity(0.7),
                                            in: Circle())
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                                .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            if let av = seleccionado {
                miniCard(av)
                    .padding(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring, value: seleccionado)
    }

    private func miniCard(_ av: Avistamiento) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(especie.habito.color.opacity(0.18))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(especie.habito.color)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(especie.nombreCientifico)
                    .font(.subheadline.italic().weight(.semibold))
                    .lineLimit(1)
                Text(av.codigo)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text(av.fecha, format: .dateTime.day().month().year())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button { seleccionado = nil } label: {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 6, y: 2)
    }
}
