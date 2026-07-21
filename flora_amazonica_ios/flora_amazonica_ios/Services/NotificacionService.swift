import Foundation
import Observation

@MainActor
@Observable
final class NotificacionService {

    var notificaciones: [Notificacion] = []
    var loading: Bool = false
    var error: AppErrorKind?

    var noLeidas: Int { notificaciones.filter { !$0.leida }.count }

    private let repo: NotificacionRepository

    init(repo: NotificacionRepository) {
        self.repo = repo
    }

    func cargar(usuarioId: String) async {
        loading = true
        error = nil
        defer { loading = false }
        do {
            notificaciones = try await repo.listar(usuarioId: usuarioId)
        } catch {
            self.error = .servidor
        }
    }

    func marcarLeida(id: String) async {
        do {
            try await repo.marcarLeida(id: id)
            if let idx = notificaciones.firstIndex(where: { $0.id == id }) {
                notificaciones[idx].leida = true
            }
        } catch {
            self.error = .servidor
        }
    }

    func marcarTodasLeidas(usuarioId: String) async {
        do {
            try await repo.marcarTodasLeidas(usuarioId: usuarioId)
            for idx in notificaciones.indices {
                notificaciones[idx].leida = true
            }
        } catch {
            self.error = .servidor
        }
    }

    func crear(_ notificacion: Notificacion) async {
        do {
            try await repo.crear(notificacion)
            // Si la notificación está dirigida al usuario actualmente cargado, la insertamos arriba.
            notificaciones.insert(notificacion, at: 0)
        } catch {
            self.error = .servidor
        }
    }

    // MARK: - Disparadores típicos

    func notificarCuentaActivada(usuarioId: String, rol: Rol) async {
        let n = Notificacion(
            id: "n-\(UUID().uuidString.prefix(8))",
            tipo: .cuentaActivada,
            titulo: "Tu cuenta fue activada",
            descripcion: "Ya puedes ingresar a FlorAmaz como \(rol.label).",
            fecha: Date(),
            leida: false,
            registroRelacionadoId: nil,
            usuarioId: usuarioId
        )
        await crear(n)
    }

    func notificarRolActualizado(usuarioId: String, nuevoRol: Rol) async {
        let n = Notificacion(
            id: "n-\(UUID().uuidString.prefix(8))",
            tipo: .rolActualizado,
            titulo: "Se actualizó tu rol",
            descripcion: "Ahora tu rol en la plataforma es: \(nuevoRol.label).",
            fecha: Date(),
            leida: false,
            registroRelacionadoId: nil,
            usuarioId: usuarioId
        )
        await crear(n)
    }

    func notificarCambioEstadoRegistro(
        usuarioId: String,
        registroId: String,
        nombreCientifico: String,
        nuevoEstado: EstadoRegistro
    ) async {
        let (tipo, titulo, descripcion): (TipoNotificacion, String, String)
        switch nuevoEstado {
        case .enRevision:
            tipo = .enRevision
            titulo = "Tu registro está en revisión"
            descripcion = "\(nombreCientifico) fue enviado al validador científico."
        case .observado:
            tipo = .observacion
            titulo = "Tu registro tiene observaciones"
            descripcion = "El validador solicitó ajustes en \(nombreCientifico)."
        case .validado:
            tipo = .validacion
            titulo = "Tu registro fue validado"
            descripcion = "\(nombreCientifico) pasó la revisión científica."
        case .rechazado:
            tipo = .rechazo
            titulo = "Tu registro fue rechazado"
            descripcion = "No fue posible aceptar \(nombreCientifico). Revisa el detalle."
        case .publicado:
            tipo = .publicacion
            titulo = "Tu registro fue publicado"
            descripcion = "\(nombreCientifico) ya está disponible en el catálogo público."
        case .borrador:
            return
        }
        let n = Notificacion(
            id: "n-\(UUID().uuidString.prefix(8))",
            tipo: tipo,
            titulo: titulo,
            descripcion: descripcion,
            fecha: Date(),
            leida: false,
            registroRelacionadoId: registroId,
            usuarioId: usuarioId
        )
        await crear(n)
    }
}
