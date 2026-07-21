import SwiftUI

/// CS-02: paso 1 — elegir hábito o "no estoy seguro".
struct MorfHabitoStep: View {

    @Bindable var store: MorfologicalSearchStore
    var onSiguiente: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Habito.allCases, id: \.self) { h in
                        cardHabito(h)
                    }
                    cardNoSeguro
                }
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            AppButton("Siguiente", variant: .primario, action: onSiguiente)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.bar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("¿Qué tipo de planta es?")
                .font(.title2.weight(.bold))
            Text("Elige el hábito que mejor se parece a la planta que viste.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func cardHabito(_ h: Habito) -> some View {
        let selected = store.habito == h
        return Button {
            withAnimation { store.habito = h }
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

    private var cardNoSeguro: some View {
        let selected = store.habito == nil
        return Button {
            withAnimation { store.habito = nil }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 36))
                    .foregroundStyle(selected ? Color.brand : .secondary)
                Text("No estoy seguro")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
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
