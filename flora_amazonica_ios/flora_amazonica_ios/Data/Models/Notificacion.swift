import Foundation
import SwiftUI

struct Notificacion: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var tipo: TipoNotificacion
    var titulo: String
    var descripcion: String
    var fecha: Date
    var leida: Bool
    var registroRelacionadoId: String?
    var usuarioId: String?
}

enum TipoNotificacion: String, Codable, CaseIterable, Hashable, Sendable {
    case validacion
    case observacion
    case rechazo
    case publicacion
    case enRevision
    case cuentaActivada
    case rolActualizado
    case sistema

    var label: String {
        switch self {
        case .validacion:     return "Validación"
        case .observacion:    return "Observación"
        case .rechazo:        return "Rechazo"
        case .publicacion:    return "Publicación"
        case .enRevision:     return "En revisión"
        case .cuentaActivada: return "Cuenta activada"
        case .rolActualizado: return "Rol actualizado"
        case .sistema:        return "Sistema"
        }
    }

    var systemImage: String {
        switch self {
        case .validacion:     return "checkmark.seal.fill"
        case .observacion:    return "exclamationmark.bubble.fill"
        case .rechazo:        return "xmark.octagon.fill"
        case .publicacion:    return "globe.americas.fill"
        case .enRevision:     return "magnifyingglass.circle.fill"
        case .cuentaActivada: return "person.crop.circle.badge.checkmark"
        case .rolActualizado: return "person.2.crop.square.stack.fill"
        case .sistema:        return "gearshape.fill"
        }
    }

    var color: Color {
        switch self {
        case .validacion:     return .green
        case .observacion:    return .orange
        case .rechazo:        return .red
        case .publicacion:    return .blue
        case .enRevision:     return .indigo
        case .cuentaActivada: return Color(red: 45/255, green: 106/255, blue: 79/255)
        case .rolActualizado: return .purple
        case .sistema:        return .gray
        }
    }
}
