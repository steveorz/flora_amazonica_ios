import Foundation

enum Rol: String, Codable, CaseIterable, Hashable, Sendable {
    case registrador
    case consultor
    case administrador
    case validador

    var label: String {
        switch self {
        case .registrador:   return "Registrador"
        case .consultor:     return "Consultor"
        case .administrador: return "Administrador"
        case .validador:     return "Validador"
        }
    }
}
