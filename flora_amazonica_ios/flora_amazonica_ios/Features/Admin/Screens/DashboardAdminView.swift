import SwiftUI

/// AM-01: panel principal del administrador.
/// Alerta de cuentas pendientes, contadores del sistema y accesos rápidos.
struct DashboardAdminView: View {

    let onJumpToUsuarios: () -> Void

    @Environment(SessionStore.self) private var session
    @Environment(UsuarioService.self) private var usuarios
    @Environment(EspecieService.self) private var especies
    @Environment(NotificacionService.self) private var notificaciones

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                greeting
                pendientesAlert
                contadoresUsuarios
                contadoresRegistros
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.appBackground)
        .navigationTitle("Inicio")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .task {
            if usuarios.usuarios.isEmpty { await usuarios.cargar() }
            if especies.especies.isEmpty { await especies.cargar() }
            if let uid = session.usuario?.id, notificaciones.notificaciones.isEmpty {
                await notificaciones.cargar(usuarioId: uid)
            }
        }
        .refreshable {
            await usuarios.cargar()
            await especies.cargar()
            if let uid = session.usuario?.id {
                await notificaciones.cargar(usuarioId: uid)
            }
        }
    }

    // MARK: - Sections

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hola, \(session.usuario?.nombres ?? "Administrador")")
                .font(.title2.weight(.semibold))
            Text("Resumen del catálogo y gestión de usuarios.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var pendientesAlert: some View {
        let pendientes = usuarios.pendientes
        if !pendientes.isEmpty {
            // Toda la tarjeta navega a Usuarios; el botón de vidrio queda como refuerzo.
            Button {
                onJumpToUsuarios()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer(minLength: 0)
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right")
                        Text("Ver pendientes")
                    }
                    .font(.subheadline.weight(.semibold))
                    // Naranja: el color predominante de la ilustración de fondo.
                    .foregroundStyle(.orange)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .padding(.bottom, 8)
                    Text("^[\(pendientes.count) cuenta](inflect: true) por activar")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Hay nuevos usuarios esperando que les asignes un rol.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 230)
                .background {
                    ZStack {
                        Color.orange
                        Image("fondo_admin_pendientes")
                            .resizable()
                            .scaledToFill()
                        // Scrim para que el texto y el vidrio se lean sobre la ilustración.
                        LinearGradient(
                            colors: [.black.opacity(0.25), .black.opacity(0.88)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)
        }
    }

    private var contadoresUsuarios: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Usuarios por rol")
                .font(.headline)
            let cols = [GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)]
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(Rol.allCases, id: \.self) { r in
                    rolTile(r)
                }
            }
        }
    }

    /// Tile de color al estilo Recordatorios: icono arriba-izquierda,
    /// número grande arriba-derecha, etiqueta abajo.
    private func rolTile(_ r: Rol) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image(systemName: icono(rol: r))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(usuarios.conteoPorRol[r] ?? 0)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 8)
            Text(r.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(12)
        .frame(height: 92)
        .background(color(rol: r).gradient, in: RoundedRectangle(cornerRadius: 16))
    }

    private var contadoresRegistros: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estado de registros")
                .font(.headline)
            estadoCard(.enRevision, imagen: "fondo_en_revision", fallback: .yellow)
            estadoCard(.validado, imagen: "fondo_validado", fallback: Color.navigationSelection)
        }
    }

    /// Tarjeta con ilustración de fondo, como la de cuentas pendientes
    /// (sin botón interno): conteo grande y etiqueta sobre el scrim.
    /// `desplazeY` positivo baja la imagen (muestra más de su parte superior);
    /// `zoom` la acerca ligeramente.
    private func estadoCard(_ estado: EstadoRegistro, imagen: String, fallback: Color,
                            desplazeY: CGFloat = 0, zoom: CGFloat = 1) -> some View {
        let n = especies.especies.filter { $0.estado == estado }.count
        return VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)
            Text("\(n)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(estado.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 104)
        .background {
            ZStack {
                fallback
                Image(imagen)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(zoom)
                    .offset(y: desplazeY)
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Helpers

    private func icono(rol: Rol) -> String {
        switch rol {
        case .registrador:   return "pencil.and.list.clipboard"
        case .consultor:     return "books.vertical.fill"
        case .administrador: return "person.badge.shield.checkmark.fill"
        case .validador:     return "checkmark.seal.fill"
        }
    }

    private func color(rol: Rol) -> Color {
        switch rol {
        case .registrador:   return .blue
        case .consultor:     return .teal
        case .administrador: return Color.navigationSelection
        case .validador:     return .purple
        }
    }

}
