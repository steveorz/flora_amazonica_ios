import Foundation

@MainActor
final class MockUsuarioRepository: UsuarioRepository {

    private var usuarios: [Usuario] = MockUsuarios.usuarios

    func listar() async throws -> [Usuario] {
        try await Task.sleep(for: .milliseconds(350))
        return usuarios
    }

    func get(id: String) async throws -> Usuario {
        try await Task.sleep(for: .milliseconds(200))
        guard let u = usuarios.first(where: { $0.id == id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        return u
    }

    func actualizarEstado(id: String, nuevo: EstadoUsuario) async throws {
        try await Task.sleep(for: .milliseconds(300))
        guard let idx = usuarios.firstIndex(where: { $0.id == id }) else { return }
        usuarios[idx].estado = nuevo
    }

    func actualizarRol(id: String, nuevo: Rol) async throws {
        try await Task.sleep(for: .milliseconds(300))
        guard let idx = usuarios.firstIndex(where: { $0.id == id }) else { return }
        usuarios[idx].rol = nuevo
    }
}
