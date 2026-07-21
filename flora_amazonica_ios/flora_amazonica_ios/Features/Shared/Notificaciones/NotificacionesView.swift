import SwiftUI

/// C-11: pantalla de notificaciones compartida por todos los roles.
struct NotificacionesView: View {

    @Environment(SessionStore.self) private var session
    @Environment(NotificacionService.self) private var servicio
    @Environment(EspecieService.self) private var especies
    @State private var destino: Especie?

    var body: some View {
        Group {
            if servicio.loading && servicio.notificaciones.isEmpty {
                listaCargando
            } else if let kind = servicio.error, servicio.notificaciones.isEmpty {
                ErrorState(kind: kind) {
                    Task { await cargar() }
                }
            } else if servicio.notificaciones.isEmpty {
                EmptyState(
                    systemImage: "bell.slash",
                    title: "Sin notificaciones",
                    message: "Cuando ocurra algo en tus registros o cuenta, te avisamos aquí."
                )
            } else {
                lista
            }
        }
        .navigationTitle("Notificaciones")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            if servicio.noLeidas > 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Marcar todas") {
                        Task { await marcarTodas() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brand)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(item: $destino) { e in
            FichaTecnicaView(especie: e)
        }
        .task { await cargar() }
        .refreshable { await cargar() }
    }

    // MARK: - Subviews

    private var lista: some View {
        List {
            ForEach(servicio.notificaciones) { n in
                Button {
                    Task { await abrir(n) }
                } label: {
                    NotificacionRow(notificacion: n)
                }
                .buttonStyle(.plain)
                .listRowBackground(n.leida ? Color.clear : Color.brand.opacity(0.06))
            }
        }
        .listStyle(.plain)
    }

    private var listaCargando: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                LoadingSkeleton(cornerRadius: 14)
                    .frame(height: 76)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Acciones

    private func cargar() async {
        guard let id = session.usuario?.id else { return }
        await servicio.cargar(usuarioId: id)
    }

    private func marcarTodas() async {
        guard let id = session.usuario?.id else { return }
        await servicio.marcarTodasLeidas(usuarioId: id)
    }

    private func abrir(_ n: Notificacion) async {
        if !n.leida {
            await servicio.marcarLeida(id: n.id)
        }
        guard let registroId = n.registroRelacionadoId else { return }
        if let local = especies.especies.first(where: { $0.id == registroId }) {
            destino = local
            return
        }
        if let remoto = try? await especies.get(id: registroId) {
            destino = remoto
        }
    }
}

// MARK: - Fila

struct NotificacionRow: View {
    let notificacion: Notificacion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notificacion.tipo.systemImage)
                .font(.system(size: 22))
                .foregroundStyle(notificacion.tipo.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(notificacion.tipo.color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(notificacion.titulo)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    if !notificacion.leida {
                        Circle()
                            .fill(Color.brand)
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                    Text(notificacion.fecha, format: .relative(presentation: .numeric))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Text(notificacion.descripcion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                Text(notificacion.tipo.label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(notificacion.tipo.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(notificacion.tipo.color.opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 6)
    }
}
