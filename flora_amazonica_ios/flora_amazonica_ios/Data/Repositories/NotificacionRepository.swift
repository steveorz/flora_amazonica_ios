import Foundation

protocol NotificacionRepository: AnyObject {
    func listar(usuarioId: String) async throws -> [Notificacion]
    func marcarLeida(id: String) async throws
    func marcarTodasLeidas(usuarioId: String) async throws
    func crear(_ notificacion: Notificacion) async throws
}
