import Foundation
import Observation

@MainActor
@Observable
final class ValorMorfologicoService {

    var valores: [ValorMorfologico] = []
    var loading: Bool = false
    var error: AppErrorKind?

    private let repo: ValorMorfologicoRepository

    init(repo: ValorMorfologicoRepository) {
        self.repo = repo
    }

    func cargar() async {
        loading = true
        error = nil
        defer { loading = false }
        do {
            valores = try await repo.listar()
        } catch {
            self.error = .servidor
        }
    }

    func actualizar(_ v: ValorMorfologico) async {
        do {
            try await repo.actualizar(v)
            if let idx = valores.firstIndex(where: { $0.codigo == v.codigo }) {
                valores[idx] = v
            }
        } catch {
            self.error = .servidor
        }
    }

    func crear(_ v: ValorMorfologico) async {
        do {
            try await repo.crear(v)
            valores.append(v)
            valores.sort { ($0.categoria, $0.orden) < ($1.categoria, $1.orden) }
        } catch {
            self.error = .servidor
        }
    }

    func eliminar(codigo: String) async {
        do {
            try await repo.eliminar(codigo: codigo)
            valores.removeAll { $0.codigo == codigo }
        } catch {
            self.error = .servidor
        }
    }

    func toggleActivo(_ v: ValorMorfologico) async {
        var nuevo = v
        nuevo.activo.toggle()
        await actualizar(nuevo)
    }

    var categorias: [String] {
        Array(Set(valores.map(\.categoria))).sorted()
    }

    func enCategoria(_ categoria: String) -> [ValorMorfologico] {
        valores
            .filter { $0.categoria == categoria }
            .sorted { $0.orden < $1.orden }
    }
}
