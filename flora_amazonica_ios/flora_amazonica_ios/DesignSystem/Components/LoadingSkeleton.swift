import SwiftUI

/// Placeholder con shimmer para estados de carga.
struct LoadingSkeleton: View {
    var cornerRadius: CGFloat = 10

    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.45), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.6)
                    .offset(x: phase * proxy.size.width)
                    .blendMode(.overlay)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        phase = 1.5
                    }
                }
        }
    }
}
