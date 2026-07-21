import SwiftUI

enum EstadoRegistro: String, Codable, CaseIterable, Hashable, Sendable {
    case borrador = "borrador"
    case enRevision = "en_revision"
    case observado = "observado"
    case validado = "validado"
    case rechazado = "rechazado"
    case publicado = "publicado"

    var label: String {
        switch self {
        case .borrador:   return "Borrador"
        case .enRevision: return "En revisión"
        case .observado:  return "Observado"
        case .validado:   return "Validado"
        case .rechazado:  return "Rechazado"
        case .publicado:  return "Publicado"
        }
    }

    var color: Color {
        switch self {
        case .borrador:   return .gray
        case .enRevision: return .blue
        case .observado:  return .orange
        case .validado:   return .blue
        case .rechazado:  return .red
        case .publicado:  return .brand
        }
    }
}
