import Foundation

@MainActor
final class MockEspecieRepository: EspecieRepository {

    private var especies: [Especie] = MockEspecies.especies

    func listar() async throws -> [Especie] {
        try await Task.sleep(for: .milliseconds(400))
        return especies
    }

    func buscar(query: String) async throws -> [Especie] {
        try await Task.sleep(for: .milliseconds(300))
        let q = query.lowercased()
        guard !q.isEmpty else { return especies }
        return especies.filter {
            $0.nombreCientifico.lowercased().contains(q) ||
            $0.nombreLocal.lowercased().contains(q) ||
            $0.familia.lowercased().contains(q)
        }
    }

    func get(id: String) async throws -> Especie {
        try await Task.sleep(for: .milliseconds(250))
        guard let e = especies.first(where: { $0.id == id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        return e
    }

    func listarPorRegistrador(_ usuarioId: String) async throws -> [Especie] {
        try await Task.sleep(for: .milliseconds(300))
        return especies.filter { $0.registradorId == usuarioId }
    }

    func crear(_ especie: Especie) async throws -> Especie {
        try await Task.sleep(for: .milliseconds(600))
        especies.append(especie)
        return especie
    }

    func actualizar(_ especie: Especie) async throws -> Especie {
        try await Task.sleep(for: .milliseconds(500))
        guard let idx = especies.firstIndex(where: { $0.id == especie.id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        especies[idx] = especie
        return especie
    }

    func eliminar(id: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        especies.removeAll { $0.id == id }
    }
}
