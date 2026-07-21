import SwiftUI

/// CS-01: home del consultor.
struct HomeConsultorView: View {

    @Environment(EspecieService.self) private var especies
    @State private var presentingMorf = false

    private var publicadas: [Especie] {
        especies.especies.filter { ($0.estado == .publicado || $0.estado == .validado) && $0.catalogId == nil }
    }

    private var familias: [String] {
        Array(Set(publicadas.map(\.familia))).sorted()
    }

    private var novedades: [Especie] {
        Array(publicadas.sorted { $0.fechaEnvio > $1.fechaEnvio }.prefix(5))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                novedadesCarousel
                identificarCard
                familiasSection
                categoriasSection
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.top, 0, for: .scrollContent)
        .ignoresSafeArea(edges: .top)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .navigationTitle("Catálogo")
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
        .navigationDestination(for: NavTarget.self) { t in
            switch t {
            case .familia(let f): CatalogoView(filterFamilia: f)
            case .habito(let h):  CatalogoView(filterHabito: h)
            case .busqueda:       CatalogoView()
            }
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
        .fullScreenCover(isPresented: $presentingMorf) {
            MorfologicalSearchView()
        }
    }

    private enum NavTarget: Hashable {
        case familia(String)
        case habito(Habito)
        case busqueda
    }

    // MARK: - Sections

    private var novedadesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(novedades) { e in
                    NavigationLink(value: e) {
                        novedadCard(e)
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .frame(height: 520)
    }

    private func novedadCard(_ e: Especie) -> some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                AsyncImage(url: portada(e)?.url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Rectangle()
                            .fill(e.habito.color.opacity(0.35))
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(e.habito.color)
                            )
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }

            // Scrim para que el texto sea legible sobre la foto
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(spacing: 5) {
                Text("Recién añadida")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.85))
                Text(e.nombreCientifico)
                    .font(.system(size: 30, weight: .bold).italic())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text("\(e.familia) · \(e.habito.label)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .containerRelativeFrame(.horizontal)
        .frame(height: 520)
    }

    private func portada(_ e: Especie) -> Foto? {
        e.fotos.first(where: { $0.tipo == .plantaCompleta }) ?? e.fotos.first
    }

    private var identificarCard: some View {
        Button {
            presentingMorf = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "leaf.arrow.triangle.circlepath")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(colors: [.brand, .brand.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 14)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Búsqueda morfológica")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Identifica plantas por sus características visuales")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var categoriasSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Explorar categorías")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)

            LazyVStack(spacing: 12) {
                ForEach(Habito.allCases, id: \.self) { h in
                    NavigationLink(value: NavTarget.habito(h)) {
                        categoriaCard(h)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func categoriaCard(_ h: Habito) -> some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .overlay {
                    Image(h.categoryImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }

            // Scrim para que el título sea legible sobre la foto
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(h.label)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .padding(16)
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var familiasSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Explorar por familia")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(familias, id: \.self) { f in
                        NavigationLink(value: NavTarget.familia(f)) {
                            Text(f)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(.primary)
                                .background(Capsule().fill(Color(.secondarySystemFill)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

}
