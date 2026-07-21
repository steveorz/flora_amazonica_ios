import SwiftUI

/// Contenedor del flujo de búsqueda morfológica (CS-02 → CS-03 → CS-04).
/// Disponible para CUALQUIER rol — preséntalo con `.fullScreenCover`.
struct MorfologicalSearchView: View {

    @State private var store = MorfologicalSearchStore()
    @State private var path: [Route] = []
    @Environment(\.dismiss) private var dismiss

    enum Route: Hashable {
        case filtros
        case resultados
    }

    var body: some View {
        NavigationStack(path: $path) {
            MorfHabitoStep(store: store, onSiguiente: { path.append(.filtros) })
                .navigationTitle("Identificar planta")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cerrar") { dismiss() }
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .filtros:
                        MorfFiltrosStep(store: store, onVerResultados: { path.append(.resultados) })
                    case .resultados:
                        ResultadosView(store: store)
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}
