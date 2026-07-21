import Foundation

protocol UsuarioRepository: AnyObject {
    func listar() async throws -> [Usuario]
    func get(id: String) async throws -> Usuario
    func actualizarEstado(id: String, nuevo: EstadoUsuario) async throws
    func actualizarRol(id: String, nuevo: Rol) async throws
}
