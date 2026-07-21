import SwiftUI

/// Banner discreto que se muestra arriba del contenido cuando no hay conexión.
/// Se incrusta automáticamente con el modificador `.offlineBanner()`.
struct OfflineBanner: View {

    @Environment(ConnectivityStore.self) private var conectividad

    var body: some View {
        if !conectividad.online {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .font(.subheadline.weight(.semibold))
                Text("Sin conexión")
                    .font(.subheadline.weight(.semibold))
                if !conectividad.pendientes.isEmpty {
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("^[\(conectividad.pendientes.count) envío](inflect: true) en cola")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(.primary)
            .glassEffect(.regular.tint(.orange.opacity(0.25)), in: Capsule())
            .padding(.horizontal, 12)
            .padding(.top, 6)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

private struct OfflineBannerOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .top, spacing: 0) {
            OfflineBanner()
                .animation(.easeInOut(duration: 0.2), value: UUID())
        }
    }
}

extension View {
    /// Inserta un banner de cristal "Sin conexión" en el borde superior del safe area.
    func offlineBanner() -> some View {
        modifier(OfflineBannerOverlay())
    }
}
