import SwiftUI

enum AppErrorKind {
    case sinConexion
    case servidor
    case sinPermisos

    var systemImage: String {
        switch self {
        case .sinConexion: return "wifi.slash"
        case .servidor:    return "exclamationmark.icloud"
        case .sinPermisos: return "lock.fill"
        }
    }

    var title: String {
        switch self {
        case .sinConexion: return "Sin conexión"
        case .servidor:    return "Error del servidor"
        case .sinPermisos: return "Sin permisos"
        }
    }

    var message: String {
        switch self {
        case .sinConexion: return "Revisa tu conexión a internet e inténtalo de nuevo."
        case .servidor:    return "Algo salió mal. Vuelve a intentar en un momento."
        case .sinPermisos: return "No tienes permisos para ver este contenido."
        }
    }
}

struct ErrorState: View {
    let kind: AppErrorKind
    var onRetry: (() -> Void)? = nil

    var body: some View {
        EmptyState(
            systemImage: kind.systemImage,
            title: kind.title,
            message: kind.message,
            actionTitle: onRetry != nil ? "Reintentar" : nil,
            action: onRetry
        )
    }
}
