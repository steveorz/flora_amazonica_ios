import SwiftUI

/// R-05: hábito (5 tarjetas, selección única) + tipo de vida.
struct HabitoStep: View {

    @Bindable var store: RegistroWizardStore

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Habito.allCases, id: \.self) { h in
                        card(h)
                    }
                }

                Divider().padding(.top, 4)

                Text("Tipo de vida")
                    .font(.headline)
                    .padding(.top, 4)

                AppRadioGroup(
                    title: "",
                    items: TipoVida.allCases,
                    selection: $store.draft.tipoVida,
                    labelFor: { $0.label }
                )
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hábito y tipo de vida")
                .font(.title2.weight(.bold))
            Text("Tu elección determina el formulario de morfología.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // Mismo estilo que las tarjetas de la búsqueda morfológica:
    // foto de la categoría con scrim y solo la palabra encima.
    private func card(_ h: Habito) -> some View {
        let selected = store.draft.habito == h
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                store.draft.habito = h
            }
        } label: {
            ZStack {
                Color.clear
                    .overlay {
                        Image(h.categoryImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }

                // Scrim: más claro cuando está seleccionada para que la foto luzca
                Rectangle()
                    .fill(.black.opacity(selected ? 0.15 : 0.45))

                Text(h.label)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selected ? Color.brand : .clear, lineWidth: 3)
            )
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.onBrand, Color.brand)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
