import SwiftUI

/// CS-09: especies marcadas como favoritas.
struct FavoritosView: View {

    @Environment(EspecieService.self) private var especies
    @Environment(FavoritosStore.self) private var favoritos

    private var lista: [Especie] {
        especies.especies.filter { favoritos.ids.contains($0.id) }
    }

    var body: some View {
        Group {
            if lista.isEmpty {
                EmptyState(
                    systemImage: "heart",
                    title: "Sin favoritos",
                    message: "Toca el corazón en cualquier ficha técnica para guardarla aquí."
                )
            } else {
                List {
                    ForEach(lista) { e in
                        ZStack {
                            SpeciesCard(especie: e, variant: .lista)
                            NavigationLink(value: e) { EmptyView() }.opacity(0)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                favoritos.toggle(e.id)
                            } label: {
                                Label("Quitar", systemImage: "heart.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favoritos")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(for: Especie.self) { e in
            FichaTecnicaView(especie: e)
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
    }
}
