import SwiftUI

enum AppToastKind {
    case exito
    case error
    case info

    var color: Color {
        switch self {
        case .exito: return .blue
        case .error: return .red
        case .info:  return .blue
        }
    }

    var systemImage: String {
        switch self {
        case .exito: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info:  return "info.circle.fill"
        }
    }
}

struct AppToast: View {
    let kind: AppToastKind
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: kind.systemImage)
                .foregroundStyle(kind.color)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular.tint(kind.color.opacity(0.18)), in: Capsule())
    }
}
