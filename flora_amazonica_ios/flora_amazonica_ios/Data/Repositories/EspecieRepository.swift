import Foundation

protocol EspecieRepository: AnyObject {
    func listar() async throws -> [Especie]
    func buscar(query: String) async throws -> [Especie]
    func get(id: String) async throws -> Especie
    func listarPorRegistrador(_ usuarioId: String) async throws -> [Especie]
    func crear(_ especie: Especie) async throws -> Especie
    func actualizar(_ especie: Especie) async throws -> Especie
    func eliminar(id: String) async throws
}
