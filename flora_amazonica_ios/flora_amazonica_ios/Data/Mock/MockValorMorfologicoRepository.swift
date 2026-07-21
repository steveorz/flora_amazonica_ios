import Foundation

@MainActor
final class MockValorMorfologicoRepository: ValorMorfologicoRepository {

    private var valores: [ValorMorfologico] = MockValoresMorfologicos.valores

    func listar() async throws -> [ValorMorfologico] {
        try await Task.sleep(for: .milliseconds(300))
        return valores.sorted { ($0.categoria, $0.orden) < ($1.categoria, $1.orden) }
    }

    func actualizar(_ valor: ValorMorfologico) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let idx = valores.firstIndex(where: { $0.codigo == valor.codigo }) else { return }
        valores[idx] = valor
    }

    func crear(_ valor: ValorMorfologico) async throws {
        try await Task.sleep(for: .milliseconds(220))
        guard !valores.contains(where: { $0.codigo == valor.codigo }) else { return }
        valores.append(valor)
    }

    func eliminar(codigo: String) async throws {
        try await Task.sleep(for: .milliseconds(180))
        valores.removeAll { $0.codigo == codigo }
    }
}
