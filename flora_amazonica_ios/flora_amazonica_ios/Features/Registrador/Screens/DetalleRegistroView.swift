import SwiftUI
import MapKit

/// R-03: detalle de un registro con mini-mapa, galería, timeline y acciones.
struct DetalleRegistroView: View {
    let especie: Especie

    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies
    @Environment(\.dismiss) private var dismiss

    @State private var presentingEditar = false
    @State private var confirmandoEliminar = false

    private var puedeEditar: Bool {
        guard especie.registradorId == session.usuario?.id else { return false }
        return especie.estado != .publicado && especie.estado != .validado
    }
    private var puedeEliminar: Bool { puedeEditar }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                cabecera
                if especie.estado == .observado || especie.estado == .rechazado {
                    bannerObservacion
                }
                galeria
                identificacionSection
                habitoSection
                if let d = especie.datosDasometricos {
                    dasometricosSection(d)
                }
                if !especie.caracteres.isEmpty {
                    caracteresSection
                }
                ubicacionSection
                historialSection
            }
            .padding()
        }
        .navigationTitle(especie.nombreLocal.isEmpty ? especie.nombreCientifico : especie.nombreLocal)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if puedeEditar || puedeEliminar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if puedeEditar {
                            Button("Editar", systemImage: "pencil") { presentingEditar = true }
                        }
                        if puedeEliminar {
                            Button("Eliminar", systemImage: "trash", role: .destructive) {
                                confirmandoEliminar = true
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog("¿Eliminar este registro?",
                            isPresented: $confirmandoEliminar,
                            titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) {
                Task {
                    try? await especies.eliminar(id: especie.id)
                    dismiss()
                }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $presentingEditar) {
            NuevoRegistroView(especieToEdit: especie)
        }
    }

    private var cabecera: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(especie.nombreCientifico)
                    .font(.title3.italic())
                Text(especie.codigoSeguimiento)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            EstadoBadge(estado: especie.estado)
        }
    }

    private var bannerObservacion: some View {
        let isError = especie.estado == .rechazado
        let titulo = isError ? "Registro rechazado" : "Tiene observaciones"
        let motivo = especie.historialEstados.last?.comentario
            ?? "El validador no dejó un comentario específico."
        let color: Color = isError ? .red : .orange
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: isError ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo).font(.subheadline.weight(.semibold))
                Text(motivo).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.12)))
    }

    private var galeria: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(especie.fotos) { foto in
                    VStack(alignment: .leading, spacing: 4) {
                        AsyncImage(url: foto.url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color(.systemGray5))
                                .overlay(ProgressView())
                        }
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(foto.tipo.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var identificacionSection: some View {
        section("Identificación") {
            row("Autor", especie.autorNombre)
            row("Familia", especie.familia)
            row("Nombre local", especie.nombreLocal)
            row("Hábito", especie.habito.label)
            row("Tipo de vida", especie.tipoVida.label)
            row("Distribución", especie.distribucionPaises.joined(separator: ", "))
            if !especie.descripcion.isEmpty {
                Divider().padding(.vertical, 4)
                Text(especie.descripcion)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
    }

    private var habitoSection: some View {
        section("Hábitat") {
            row("Tipo", especie.ubicacion.tipoHabitat)
            row("Altitud", "\(Int(especie.ubicacion.altitud)) m")
        }
    }

    private func dasometricosSection(_ d: DatosDasometricos) -> some View {
        section("Datos dasométricos") {
            row("Altura total", "\(Dasometria.formato(d.altura)) m")
            row("CAP", "\(Dasometria.formato(d.cap)) cm")
            row("DAP", "\(Dasometria.formato(d.dap)) cm")
            row("Diám. copa ‖", "\(Dasometria.formato(d.diamCopaParalelo)) m")
            row("Diám. copa ⊥", "\(Dasometria.formato(d.diamCopaPerpendicular)) m")
            row("Inicio copa", "\(Dasometria.formato(d.alturaInicioCopa)) m")
        }
    }

    private var caracteresSection: some View {
        section("Caracteres morfológicos") {
            ForEach(especie.caracteres.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                VStack(alignment: .leading, spacing: 2) {
                    Text(key.capitalized).font(.caption).foregroundStyle(.secondary)
                    Text(value).font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
    }

    private var ubicacionSection: some View {
        let coord = CLLocationCoordinate2D(latitude: especie.ubicacion.lat,
                                           longitude: especie.ubicacion.long)
        return section("Ubicación") {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))) {
                Marker(especie.nombreLocal, coordinate: coord)
                    .tint(Color.brand)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)

            row("Latitud", String(format: "%.5f", especie.ubicacion.lat))
            row("Longitud", String(format: "%.5f", especie.ubicacion.long))
            row("Referencia", especie.ubicacion.referencia)
        }
    }

    private var historialSection: some View {
        section("Historial") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(especie.historialEstados) { h in
                    HStack(alignment: .top, spacing: 12) {
                        Circle().fill(h.estado.color)
                            .frame(width: 10, height: 10)
                            .padding(.top, 6)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(h.estado.label).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(h.fecha, format: .dateTime.day().month().year())
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            if let c = h.comentario, !c.isEmpty {
                                Text(c).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
