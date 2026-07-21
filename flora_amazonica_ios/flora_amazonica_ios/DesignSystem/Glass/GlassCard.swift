import SwiftUI

/// Tarjeta flotante con material Liquid Glass.
/// Úsala SOLO para acciones o tarjetas que flotan sobre contenido —
/// nunca para contenido principal (listas, fichas).
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var tint: Color? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .glassEffect(
                tint.map { .regular.tint($0) } ?? .regular,
                in: .rect(cornerRadius: cornerRadius)
            )
    }
}
