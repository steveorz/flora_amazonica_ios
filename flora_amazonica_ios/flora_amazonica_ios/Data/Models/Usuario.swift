import Foundation

nonisolated struct Usuario: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var nombres: String
    var apellidos: String
    var dni: String
    var email: String
    var institucion: String
    var cargo: String
    var rol: Rol
    var estado: EstadoUsuario
    var fechaRegistro: Date
    var avatarUrl: URL?

    var nombreCompleto: String { "\(nombres) \(apellidos)" }
}

enum EstadoUsuario: String, Codable, CaseIterable, Hashable, Sendable {
    case activo
    case inactivo
    case pendiente
}
