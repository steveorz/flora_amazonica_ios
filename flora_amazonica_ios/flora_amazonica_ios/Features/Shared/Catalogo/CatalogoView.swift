import SwiftUI

/// Catálogo filtrable / buscable. Reutilizado por la tab Buscar (CS-10),
/// y por los chips de familia / cards de hábito del home consultor.
struct CatalogoView: View {

    var filterFamilia: String? = nil
    var filterHabito: Habito? = nil
    var tituloOverride: String? = nil
    var soloPublicadas: Bool = true

    @Environment(EspecieService.self) private var especies
    @State private var search: String = ""

    private var filtradas: [Especie] {
        var list = especies.especies
        if soloPublicadas {
            list = list.filter { ($0.estado == .publicado || $0.estado == .validado) && $0.catalogId == nil }
        }
        if let f = filterFamilia {
            list = list.filter { $0.familia == f }
        }
        if let h = filterHabito {
            list = list.filter { $0.habito == h }
        }
        if !search.isEmpty {
            let q = search.lowercased()
            list = list.filter {
                $0.nombreCientifico.lowercased().contains(q) ||
                $0.nombreLocal.lowercased().contains(q) ||
                $0.familia.lowercased().contains(q)
            }
        }
        return list
    }

    var body: some View {
        Group {
            if filtradas.isEmpty {
                EmptyState(
                    systemImage: "magnifyingglass",
                    title: search.isEmpty ? "Sin resultados" : "Nada coincide",
                    message: search.isEmpty
                        ? "No hay especies con ese filtro."
                        : "Prueba con otro nombre, familia o nombre común."
                )
            } else {
                List {
                    ForEach(filtradas) { e in
                        ZStack {
                            SpeciesCard(especie: e, variant: .lista)
                            NavigationLink(value: e) { EmptyView() }.opacity(0)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $search, prompt: "Nombre científico, común o familia")
        .navigationTitle(tituloOverride ?? defaultTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Especie.self) { e in
            FichaTecnicaView(especie: e)
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
    }

    private var defaultTitle: String {
        if let f = filterFamilia { return f }
        if let h = filterHabito { return h.label }
        return "Buscar"
    }
}
