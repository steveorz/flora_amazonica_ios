import Foundation

class RealNotificacionRepository: NotificacionRepository {
    private let apiClient = APIClient.shared
    
    private struct NotificationDTO: Decodable {
        let id: String
        let event_type: String
        let title: String
        let description: String
        let is_read: Bool
        let species_record_id: String?
        let user_id: String
        let created_at: Date
        let metadata: NotificationMetadata?
        
        struct NotificationMetadata: Decodable {
            let new_status: String?
            let status: String?
        }
        
        func toNotificacion() -> Notificacion {
            var typeEnum: TipoNotificacion
            switch event_type {
            case "account_activated": typeEnum = .cuentaActivada
            case "account_deactivated": typeEnum = .sistema // Podríamos agregar .cuentaDesactivada si existiera, pero .sistema o .rechazo está bien
            case "record_received": typeEnum = .enRevision
            case "status_changed": 
                if let status = metadata?.new_status {
                    switch status {
                    case "observado": typeEnum = .observacion
                    case "rechazado": typeEnum = .rechazo
                    case "publicado": typeEnum = .publicacion
                    case "validado": typeEnum = .validacion
                    default: typeEnum = .validacion
                    }
                } else {
                    typeEnum = .validacion
                }
            default: typeEnum = .sistema
            }
            
            return Notificacion(
                id: id,
                tipo: typeEnum,
                titulo: title,
                descripcion: description,
                fecha: created_at,
                leida: is_read,
                registroRelacionadoId: species_record_id,
                usuarioId: user_id
            )
        }
    }
    
    func listar(usuarioId: String) async throws -> [Notificacion] {
        let dtos: [NotificationDTO] = try await apiClient.request(endpoint: "/notifications/user/\(usuarioId)")
        return dtos.map { $0.toNotificacion() }
    }
    
    func marcarLeida(id: String) async throws {
        let _ : [String: String] = try await apiClient.request(endpoint: "/notifications/\(id)/read", method: "PATCH")
    }
    
    func marcarTodasLeidas(usuarioId: String) async throws {
        let _ : [String: String] = try await apiClient.request(endpoint: "/notifications/user/\(usuarioId)/read-all", method: "PATCH")
    }
    
    func crear(_ notificacion: Notificacion) async throws {
        // ... Usually done on backend, but if needed from app
    }
}
