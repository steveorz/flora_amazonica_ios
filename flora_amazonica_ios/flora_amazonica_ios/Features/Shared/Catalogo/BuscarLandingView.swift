import SwiftUI

struct BuscarLandingView: View {
    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies
    
    @State private var searchText = ""
    @State private var presentingMorf = false
    
    private var publicadas: [Especie] {
        especies.especies.filter { $0.estado == .publicado || $0.estado == .validado }
    }
    
    // Filter species based on search text
    private var searchResults: [Especie] {
        guard !searchText.isEmpty else { return [] }
        let q = searchText.lowercased()
        return publicadas.filter {
            $0.nombreCientifico.lowercased().contains(q) ||
            $0.nombreLocal.lowercased().contains(q) ||
            $0.familia.lowercased().contains(q)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if searchText.isEmpty {
                    morphologicalSearchCard
                        .padding(.horizontal, 16)
                } else {
                    // 3. Search Results
                    searchResultsList
                }
            }
            .padding(.vertical, 16)
        }
        .searchable(text: $searchText, prompt: "Nombre científico, común o familia")
        .navigationTitle("Buscar")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .fullScreenCover(isPresented: $presentingMorf) {
            MorfologicalSearchView()
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
    }
    
    // MARK: - Components
    
    private var morphologicalSearchCard: some View {
        Button {
            presentingMorf = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "leaf.arrow.triangle.circlepath")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.onBrand)
                    .frame(width: 64, height: 64)
                    .glassEffect(.regular, in: .circle)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Búsqueda morfológica")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.onBrand)
                    Text("Identifica plantas por sus características visuales: hábito, hojas, flores y frutos.")
                        .font(.subheadline)
                        .foregroundStyle(Color.onBrand.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: 6) {
                    Text("Identificar planta")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.onBrand)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(
                LinearGradient(colors: [.brand, .brand.opacity(0.65)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 24)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var searchResultsList: some View {
        if searchResults.isEmpty {
            EmptyState(
                systemImage: "magnifyingglass",
                title: "Nada coincide",
                message: "Prueba con otro nombre, familia o nombre común."
            )
            .padding(.top, 40)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { e in
                    NavigationLink(destination: FichaTecnicaView(especie: e)) {
                        SpeciesCard(especie: e, variant: .lista)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .padding(.leading, 96)
                }
            }
        }
    }
    
}

// Micro-animation style for grid cards
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
