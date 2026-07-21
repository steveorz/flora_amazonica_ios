import SwiftUI

/// Indicador 'Paso X de N' con barra de progreso. Pensado para el wizard.
struct ProgressStepper: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Paso \(current) de \(total)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            ProgressView(value: Double(current), total: Double(total))
                .tint(.brand)
        }
    }
}
