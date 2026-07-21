import Foundation

protocol ValorMorfologicoRepository: AnyObject {
    func listar() async throws -> [ValorMorfologico]
    func actualizar(_ valor: ValorMorfologico) async throws
    func crear(_ valor: ValorMorfologico) async throws
    func eliminar(codigo: String) async throws
}
