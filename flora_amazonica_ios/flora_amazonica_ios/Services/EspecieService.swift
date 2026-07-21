import Foundation
import Observation

/// Estado observable del catálogo de especies.
/// Inyectado en el Environment. Cambiar a HTTP solo requiere pasar otra impl de EspecieRepository.
@MainActor
@Observable
final class EspecieService {

    var especies: [Especie] = []
    var loading: Bool = false
    var error: AppErrorKind?

    private let repo: EspecieRepository

    init(repo: EspecieRepository) {
        self.repo = repo
    }

    func cargar() async {
        loading = true
        error = nil
        defer { loading = false }
        do {
            especies = try await repo.listar()
        } catch {
            self.error = .servidor
        }
    }

    func buscar(_ query: String) async {
        loading = true
        defer { loading = false }
        do {
            especies = try await repo.buscar(query: query)
        } catch {
            self.error = .servidor
        }
    }

    func get(id: String) async throws -> Especie {
        try await repo.get(id: id)
    }

    func registrosDe(usuarioId: String) -> [Especie] {
        especies.filter { $0.registradorId == usuarioId }
    }

    @discardableResult
    func crear(_ especie: Especie) async throws -> Especie {
        let nueva = try await repo.crear(especie)
        especies.append(nueva)
        return nueva
    }

    @discardableResult
    func actualizar(_ especie: Especie) async throws -> Especie {
        let actualizada = try await repo.actualizar(especie)
        if let idx = especies.firstIndex(where: { $0.id == especie.id }) {
            especies[idx] = actualizada
        }
        return actualizada
    }

    func eliminar(id: String) async throws {
        try await repo.eliminar(id: id)
        especies.removeAll { $0.id == id }
    }
}
