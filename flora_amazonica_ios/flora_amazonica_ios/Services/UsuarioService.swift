import Foundation
import Observation

@MainActor
@Observable
final class UsuarioService {

    var usuarios: [Usuario] = []
    var loading: Bool = false
    var error: AppErrorKind?

    private let repo: UsuarioRepository

    init(repo: UsuarioRepository) {
        self.repo = repo
    }

    func cargar() async {
        loading = true
        error = nil
        defer { loading = false }
        do {
            usuarios = try await repo.listar()
        } catch {
            self.error = .servidor
        }
    }

    func actualizarEstado(id: String, nuevo: EstadoUsuario) async throws {
        try await repo.actualizarEstado(id: id, nuevo: nuevo)
        if let idx = usuarios.firstIndex(where: { $0.id == id }) {
            usuarios[idx].estado = nuevo
        }
    }

    func actualizarRol(id: String, nuevo: Rol) async throws {
        try await repo.actualizarRol(id: id, nuevo: nuevo)
        if let idx = usuarios.firstIndex(where: { $0.id == id }) {
            usuarios[idx].rol = nuevo
        }
    }

    func get(id: String) -> Usuario? {
        usuarios.first { $0.id == id }
    }

    // MARK: - Conteos para el dashboard

    var conteoPorRol: [Rol: Int] {
        Dictionary(grouping: usuarios, by: \.rol).mapValues(\.count)
    }

    var conteoPorEstado: [EstadoUsuario: Int] {
        Dictionary(grouping: usuarios, by: \.estado).mapValues(\.count)
    }

    var pendientes: [Usuario] {
        usuarios
            .filter { $0.estado == .pendiente }
            .sorted { $0.fechaRegistro > $1.fechaRegistro }
    }
}
