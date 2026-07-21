import SwiftUI

/// AM-02: lista de usuarios con búsqueda y chips de filtro.
struct UsuariosView: View {

    enum FiltroEstado: String, CaseIterable, Identifiable, Hashable {
        case todos, pendientes, activos, inactivos
        var id: String { rawValue }
        var label: String {
            switch self {
            case .todos:      return "Todos"
            case .pendientes: return "Pendientes"
            case .activos:    return "Activos"
            case .inactivos:  return "Inactivos"
            }
        }
    }

    @Environment(UsuarioService.self) private var servicio
    @State private var search: String = ""
    @State private var filtroEstado: FiltroEstado = .todos
    @State private var rolesSeleccionados: Set<Rol> = []

    private var filtrados: [Usuario] {
        var list = servicio.usuarios

        switch filtroEstado {
        case .todos: break
        case .pendientes: list = list.filter { $0.estado == .pendiente }
        case .activos:    list = list.filter { $0.estado == .activo }
        case .inactivos:  list = list.filter { $0.estado == .inactivo }
        }

        if !rolesSeleccionados.isEmpty {
            list = list.filter { rolesSeleccionados.contains($0.rol) }
        }

        if !search.isEmpty {
            let q = search.lowercased()
            list = list.filter {
                $0.nombreCompleto.lowercased().contains(q) ||
                $0.email.lowercased().contains(q) ||
                $0.institucion.lowercased().contains(q)
            }
        }

        return list.sorted { ($0.estado == .pendiente && $1.estado != .pendiente)
                              || $0.nombreCompleto < $1.nombreCompleto }
    }

    var body: some View {
        Group {
            if servicio.loading && servicio.usuarios.isEmpty {
                listaCargando
            } else if let kind = servicio.error, servicio.usuarios.isEmpty {
                ErrorState(kind: kind) {
                    Task { await servicio.cargar() }
                }
            } else {
                contenido
            }
        }
        .searchable(text: $search, prompt: "Nombre, email o institución")
        .navigationTitle("Usuarios")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(for: Usuario.self) { u in
            UsuarioDetalleView(usuarioId: u.id)
        }
        .task {
            if servicio.usuarios.isEmpty { await servicio.cargar() }
        }
        .refreshable { await servicio.cargar() }
    }

    private var contenido: some View {
        VStack(spacing: 0) {
            filtros
            if filtrados.isEmpty {
                EmptyState(
                    systemImage: "person.crop.circle.badge.questionmark",
                    title: search.isEmpty ? "Sin coincidencias" : "Nada coincide",
                    message: search.isEmpty
                        ? "Prueba a quitar algún filtro."
                        : "Prueba con otro nombre, email o institución."
                )
            } else {
                List {
                    ForEach(filtrados) { u in
                        ZStack {
                            UsuarioCardRow(usuario: u)
                            NavigationLink(value: u) { EmptyView() }.opacity(0)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var filtros: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FiltroEstado.allCases) { f in
                        chipEstado(f)
                    }
                }
                .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Rol.allCases, id: \.self) { r in
                        chipRol(r)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 6)
    }

    private func chipEstado(_ f: FiltroEstado) -> some View {
        let isOn = filtroEstado == f
        return Button {
            filtroEstado = f
        } label: {
            Text(f.label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(isOn ? Color.onBrand : Color.primary)
                .glassEffect(
                    isOn ? .regular.tint(Color.brand).interactive() : .regular.interactive(),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private func chipRol(_ r: Rol) -> some View {
        let isOn = rolesSeleccionados.contains(r)
        return Button {
            if isOn { rolesSeleccionados.remove(r) } else { rolesSeleccionados.insert(r) }
        } label: {
            Text(r.label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(isOn ? .white : .primary)
                .glassEffect(
                    isOn ? .regular.tint(Color.navigationSelection).interactive() : .regular.interactive(),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private var listaCargando: some View {
        VStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in
                LoadingSkeleton(cornerRadius: 14).frame(height: 78)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Tarjeta de usuario en lista

struct UsuarioCardRow: View {
    let usuario: Usuario

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ProfileAvatarView(user: usuario)

            VStack(alignment: .leading, spacing: 3) {
                Text(usuario.nombreCompleto)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(usuario.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(usuario.institucion)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                EstadoUsuarioBadge(estado: usuario.estado)
                Text(usuario.rol.label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct EstadoUsuarioBadge: View {
    let estado: EstadoUsuario

    var label: String {
        switch estado {
        case .activo:    return "Activo"
        case .inactivo:  return "Inactivo"
        case .pendiente: return "Pendiente"
        }
    }

    var color: Color {
        switch estado {
        case .activo:    return Color.navigationSelection
        case .inactivo:  return .gray
        case .pendiente: return .orange
        }
    }

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .glassEffect(.regular.tint(color.opacity(0.25)), in: Capsule())
    }
}
