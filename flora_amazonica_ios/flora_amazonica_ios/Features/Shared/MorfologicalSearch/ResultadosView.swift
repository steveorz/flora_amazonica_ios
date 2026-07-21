import SwiftUI

/// CS-04: resultados ordenados por coincidencias. Toggle lista/galería.
struct ResultadosView: View {

    @Bindable var store: MorfologicalSearchStore
    @Environment(EspecieService.self) private var especies

    enum Modo: String, CaseIterable { case lista, galeria }
    @State private var modo: Modo = .lista

    private var resultados: [MorfMatch] {
        store.evaluar(especies.especies)
    }

    var body: some View {
        VStack(spacing: 0) {
            chipsAplicados
            controles
            if resultados.isEmpty {
                empty
            } else {
                ScrollView {
                    switch modo {
                    case .lista:   lista
                    case .galeria: galeria
                    }
                }
            }
        }
        .navigationTitle("Resultados")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Especie.self) { e in
            FichaTecnicaView(especie: e)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var chipsAplicados: some View {
        let activos = chipsActivos
        if !activos.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(activos, id: \.id) { chip in
                        Button {
                            store.limpiar(dimension: chip.dimensionId, opcion: chip.opcion)
                        } label: {
                            HStack(spacing: 4) {
                                Text(chip.label)
                                    .font(.caption.weight(.medium))
                                Image(systemName: "xmark")
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(Color.brand)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .glassEffect(.regular.tint(Color.brand.opacity(0.18)), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(.bar)
        }
    }

    private struct ChipAplicado {
        let id: String
        let dimensionId: String
        let opcion: String
        let label: String
    }

    private var chipsActivos: [ChipAplicado] {
        var result: [ChipAplicado] = []
        if let h = store.habito {
            result.append(.init(id: "habito", dimensionId: "habito", opcion: h.rawValue, label: h.label))
        }
        for (dimId, opciones) in store.selecciones {
            for op in opciones {
                result.append(.init(id: "\(dimId)-\(op)", dimensionId: dimId, opcion: op, label: op))
            }
        }
        return result
    }

    @ViewBuilder
    private var controles: some View {
        HStack {
            Text("\(resultados.count) \(resultados.count == 1 ? "especie" : "especies")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Picker("", selection: $modo) {
                Image(systemName: "list.bullet").tag(Modo.lista)
                Image(systemName: "square.grid.2x2").tag(Modo.galeria)
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Listas

    private var lista: some View {
        LazyVStack(spacing: 0) {
            ForEach(resultados) { m in
                NavigationLink(value: m.especie) {
                    HStack(alignment: .top, spacing: 12) {
                        SpeciesCard(especie: m.especie, variant: .lista)
                        if m.total > 0 {
                            coincidenciaBadge(m)
                        }
                    }
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 80)
            }
        }
        .padding(.horizontal, 16)
    }

    private var galeria: some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: cols, spacing: 14) {
            ForEach(resultados) { m in
                NavigationLink(value: m.especie) {
                    VStack(alignment: .leading, spacing: 6) {
                        SpeciesCard(especie: m.especie, variant: .galeria)
                        if m.total > 0 {
                            coincidenciaBadge(m)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private func coincidenciaBadge(_ m: MorfMatch) -> some View {
        Text("\(m.coincidencias)/\(m.total)")
            .font(.caption2.monospacedDigit().weight(.semibold))
            .foregroundStyle(Color.brand)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.brand.opacity(0.12), in: Capsule())
    }

    private var empty: some View {
        EmptyState(
            systemImage: "magnifyingglass",
            title: "Sin resultados",
            message: "Afloja algún filtro o cambia de hábito y vuelve a intentar.",
            actionTitle: "Quitar filtros",
            action: { store.selecciones = [:] }
        )
    }
}
