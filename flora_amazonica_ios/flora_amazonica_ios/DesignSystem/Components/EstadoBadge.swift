import SwiftUI

/// Cápsula de cristal tintada según el estado del registro.
struct EstadoBadge: View {
    let estado: EstadoRegistro

    var body: some View {
        Text(estado.label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(estado.color)
            .glassEffect(.regular.tint(estado.color.opacity(0.25)), in: Capsule())
    }
}
