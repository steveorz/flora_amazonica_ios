import SwiftUI

/// CS-03: paso 2 — filtros combinables con contador EN VIVO.
struct MorfFiltrosStep: View {

    @Bindable var store: MorfologicalSearchStore
    @Environment(EspecieService.self) private var especies
    var onVerResultados: () -> Void

    @State private var expandidas: Set<String> = ["Florales"]

    private var conteo: Int {
        store.evaluar(especies.especies).count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                ForEach(MorfDimensions.categorias, id: \.self) { cat in
                    seccionCategoria(cat)
                }
            }
            .padding(20)
        }
        .navigationTitle("Caracteres")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            barraResultados
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("¿Qué caracteres viste?")
                .font(.title2.weight(.bold))
            Text("Marca todo lo que aplique. Puedes combinar de varias secciones.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func seccionCategoria(_ categoria: String) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandidas.contains(categoria) },
                set: { v in
                    if v { expandidas.insert(categoria) } else { expandidas.remove(categoria) }
                }
            )
        ) {
            VStack(spacing: 14) {
                ForEach(MorfDimensions.dimensiones(de: categoria)) { dim in
                    dimensionView(dim)
                }
            }
            .padding(.top, 12)
        } label: {
            HStack {
                Text(categoria).font(.headline)
                if let count = countSeleccionadas(categoria), count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brand, in: Capsule())
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func dimensionView(_ dim: MorfDimension) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dim.titulo)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            AppChips(
                items: dim.opciones,
                selection: Binding(
                    get: {
                        let labels = store.selecciones[dim.id] ?? []
                        return Set(dim.opciones.filter { labels.contains($0.label) })
                    },
                    set: { nuevas in
                        store.selecciones[dim.id] = Set(nuevas.map(\.label))
                        if store.selecciones[dim.id]?.isEmpty ?? true {
                            store.selecciones.removeValue(forKey: dim.id)
                        }
                    }
                ),
                labelFor: { $0.label }
            )
        }
    }

    private func countSeleccionadas(_ categoria: String) -> Int? {
        let dims = MorfDimensions.dimensiones(de: categoria)
        return dims.reduce(0) { $0 + (store.selecciones[$1.id]?.count ?? 0) }
    }

    private var barraResultados: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(conteo)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.brand)
                    .contentTransition(.numericText())
                    .animation(.default, value: conteo)
                Text(conteo == 1 ? "especie coincide" : "especies coinciden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            AppButton("Ver resultados", systemImage: "arrow.right", variant: .atencion,
                      action: onVerResultados)
                .disabled(conteo == 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.bar)
    }
}
