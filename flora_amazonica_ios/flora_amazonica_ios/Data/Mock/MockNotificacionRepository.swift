import Foundation

@MainActor
final class MockNotificacionRepository: NotificacionRepository {

    private var notificaciones: [Notificacion] = MockNotificaciones.notificaciones

    func listar(usuarioId: String) async throws -> [Notificacion] {
        try await Task.sleep(for: .milliseconds(300))
        // Devolvemos las dirigidas al usuario o las globales (usuarioId == nil)
        return notificaciones
            .filter { $0.usuarioId == nil || $0.usuarioId == usuarioId }
            .sorted { $0.fecha > $1.fecha }
    }

    func marcarLeida(id: String) async throws {
        try await Task.sleep(for: .milliseconds(150))
        guard let idx = notificaciones.firstIndex(where: { $0.id == id }) else { return }
        notificaciones[idx].leida = true
    }

    func marcarTodasLeidas(usuarioId: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        for idx in notificaciones.indices where
            notificaciones[idx].usuarioId == nil || notificaciones[idx].usuarioId == usuarioId {
            notificaciones[idx].leida = true
        }
    }

    func crear(_ notificacion: Notificacion) async throws {
        try await Task.sleep(for: .milliseconds(180))
        notificaciones.insert(notificacion, at: 0)
    }
}
