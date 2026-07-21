import SwiftUI
import MapKit

/// R-11: ubicación con mapa interactivo. La coordenada es el centro del mapa.
struct UbicacionStep: View {

    @Bindable var store: RegistroWizardStore
    @Environment(EspecieService.self) private var especies

    @State private var coordinate: CLLocationCoordinate2D
    @State private var position: MapCameraPosition
    @State private var referencia: String
    @State private var tipoHabitat: String
    @State private var duplicadoCercano: Especie?
    @State private var buscandoUbicacion = false
    @State private var errorUbicacion: String?

    init(store: RegistroWizardStore) {
        self.store = store
        let initial = store.draft.ubicacion.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.long)
        } ?? CLLocationCoordinate2D(latitude: -3.7437, longitude: -73.2516)
        _coordinate = State(initialValue: initial)
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: initial,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )))
        _referencia = State(initialValue: store.draft.ubicacion?.referencia ?? "")
        _tipoHabitat = State(initialValue: store.draft.ubicacion?.tipoHabitat ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                mapa
                coordenadas
                botonMiUbicacion
                if let d = duplicadoCercano {
                    duplicadoBanner(d)
                }
                AppTextField(
                    title: "Referencia",
                    text: $referencia,
                    placeholder: "Ej.: Borde sur del aguajal"
                )
                .onChange(of: referencia) { _, _ in actualizarDraft() }

                AppTextField(
                    title: "Tipo de hábitat *",
                    text: $tipoHabitat,
                    placeholder: "Ej.: Bosque de tierra firme"
                )
                .onChange(of: tipoHabitat) { _, _ in actualizarDraft() }
            }
            .padding(20)
        }
        .onAppear { evaluarDuplicado() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ubicación")
                .font(.title2.weight(.bold))
            Text("Centra el mapa en el punto exacto del registro.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var mapa: some View {
        ZStack {
            Map(position: $position)
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange(frequency: .onEnd) { ctx in
                    coordinate = ctx.camera.centerCoordinate
                    actualizarDraft()
                    evaluarDuplicado()
                }

            // Pin fijo al centro de la vista (no del mapa).
            VStack(spacing: 0) {
                Image(systemName: "mappin")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.brand)
                    .shadow(radius: 2, y: 1)
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(Color.brand.opacity(0.75))
            }
            .offset(y: -16)
            .allowsHitTesting(false)
        }
        .frame(height: 290)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var coordenadas: some View {
        HStack {
            label("Latitud",  value: String(format: "%.5f", coordinate.latitude))
            Spacer()
            label("Longitud", value: String(format: "%.5f", coordinate.longitude))
        }
    }

    private func label(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.monospacedDigit().weight(.medium))
        }
    }

    private var botonMiUbicacion: some View {
        VStack(spacing: 6) {
            AppButton(
                buscandoUbicacion ? "Obteniendo ubicación…" : "Centrar en mi ubicación",
                systemImage: "location.fill",
                variant: .secundario
            ) {
                centrarEnMiUbicacion()
            }
            .frame(maxWidth: .infinity)
            .disabled(buscandoUbicacion)

            if let errorUbicacion {
                Text(errorUbicacion)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func centrarEnMiUbicacion() {
        guard !buscandoUbicacion else { return }
        buscandoUbicacion = true
        errorUbicacion = nil
        Task {
            do {
                let coord = try await LocationProvider.ubicacionActual()
                withAnimation {
                    position = .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                    coordinate = coord
                }
                actualizarDraft()
                evaluarDuplicado()
            } catch {
                errorUbicacion = error.localizedDescription
            }
            buscandoUbicacion = false
        }
    }

    private func duplicadoBanner(_ e: Especie) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Coordenadas muy cercanas a otro registro")
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 4) {
                    Text(e.nombreCientifico)
                        .font(.caption.italic())
                    Text("— \(e.codigoSeguimiento)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.12))
        )
    }

    private func actualizarDraft() {
        store.draft.ubicacion = Ubicacion(
            lat: coordinate.latitude,
            long: coordinate.longitude,
            referencia: referencia,
            altitud: 110,
            tipoHabitat: tipoHabitat
        )
    }

    private func evaluarDuplicado() {
        duplicadoCercano = especies.especies.first {
            $0.id != store.draft.id &&
            abs($0.ubicacion.lat - coordinate.latitude) < 0.0008 &&
            abs($0.ubicacion.long - coordinate.longitude) < 0.0008
        }
    }
}
