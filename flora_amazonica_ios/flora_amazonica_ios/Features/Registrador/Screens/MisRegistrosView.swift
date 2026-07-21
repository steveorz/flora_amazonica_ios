import SwiftUI

/// R-02: lista con búsqueda, filtros por estado, pull-to-refresh, swipe edit/delete.
struct MisRegistrosView: View {

    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies

    enum Orden: String, CaseIterable, Identifiable {
        case recientes = "Más recientes"
        case antiguos  = "Más antiguos"
        case nombre    = "Nombre (A–Z)"
        case estado    = "Estado"
        var id: String { rawValue }
    }

    @State private var query: String = ""
    @State private var filtros: Set<EstadoRegistro>
    @State private var orden: Orden = .recientes
    @State private var presentingEditar: Especie?
    @State private var confirmandoEliminar: Especie?

    /// `filtroInicial` permite llegar ya filtrado (p. ej. desde el resumen del home).
    init(filtroInicial: EstadoRegistro? = nil) {
        _filtros = State(initialValue: filtroInicial.map { [$0] } ?? [])
    }

    private var misRegistros: [Especie] {
        guard let uid = session.usuario?.id else { return [] }
        return especies.registrosDe(usuarioId: uid)
    }

    private var filtrados: [Especie] {
        let base = misRegistros.filter { e in
            if !filtros.isEmpty && !filtros.contains(e.estado) { return false }
            if !query.isEmpty {
                let q = query.lowercased()
                return e.nombreCientifico.lowercased().contains(q) ||
                       e.nombreLocal.lowercased().contains(q) ||
                       e.familia.lowercased().contains(q)
            }
            return true
        }
        switch orden {
        case .recientes:
            return base.sorted { $0.fechaEnvio > $1.fechaEnvio }
        case .antiguos:
            return base.sorted { $0.fechaEnvio < $1.fechaEnvio }
        case .nombre:
            return base.sorted {
                $0.nombreCientifico.localizedCaseInsensitiveCompare($1.nombreCientifico) == .orderedAscending
            }
        case .estado:
            return base.sorted { indiceEstado($0.estado) < indiceEstado($1.estado) }
        }
    }

    private func indiceEstado(_ e: EstadoRegistro) -> Int {
        EstadoRegistro.allCases.firstIndex(of: e) ?? 0
    }

    var body: some View {
        Group {
            if misRegistros.isEmpty && !especies.loading {
                EmptyState(
                    systemImage: "tray",
                    title: "Sin registros",
                    message: "Cuando crees registros aparecerán aquí.",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                listaPrincipal
            }
        }
        .navigationTitle("Mis registros")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Ordenar por", selection: $orden) {
                        ForEach(Orden.allCases) { o in
                            Text(o.rawValue).tag(o)
                        }
                    }
                } label: {
                    Label("Ordenar", systemImage: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(for: Especie.self) { e in
            DetalleRegistroView(especie: e)
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
        .refreshable {
            await especies.cargar()
        }
        .searchable(text: $query, prompt: "Buscar por nombre, familia o local")
        .confirmationDialog(
            "¿Eliminar este registro?",
            isPresented: Binding(get: { confirmandoEliminar != nil },
                                 set: { if !$0 { confirmandoEliminar = nil } }),
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if let e = confirmandoEliminar {
                    Task { try? await especies.eliminar(id: e.id) }
                }
                confirmandoEliminar = nil
            }
            Button("Cancelar", role: .cancel) { confirmandoEliminar = nil }
        }
        .fullScreenCover(item: $presentingEditar) { e in
            NuevoRegistroView(especieToEdit: e)
        }
    }

    @ViewBuilder
    private var listaPrincipal: some View {
        List {
            Section {
                AppChips(
                    items: EstadoRegistro.allCases,
                    selection: $filtros,
                    labelFor: { $0.label }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if filtrados.isEmpty {
                Text("No hay resultados.")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(filtrados) { e in
                    ZStack {
                        SpeciesCard(especie: e, variant: .lista)
                        NavigationLink(value: e) { EmptyView() }
                            .opacity(0)
                    }
                    .listRowSeparator(.visible)
                    .swipeActions(edge: .trailing) {
                        if puedeEditar(e) {
                            Button {
                                presentingEditar = e
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            .tint(.blue)

                            Button(role: .destructive) {
                                confirmandoEliminar = e
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func puedeEditar(_ e: Especie) -> Bool {
        e.estado != .publicado && e.estado != .validado
    }
}
