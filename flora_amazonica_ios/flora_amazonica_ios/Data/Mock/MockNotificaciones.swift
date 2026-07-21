import Foundation

enum MockNotificaciones {

    static let notificaciones: [Notificacion] = {
        let now = Date()
        func fecha(horasAtras: Double) -> Date {
            now.addingTimeInterval(-horasAtras * 3600)
        }

        return [
            // u-001 (María, registradora) — destinataria de la mayoría de validaciones
            Notificacion(
                id: "n-001",
                tipo: .validacion,
                titulo: "Tu registro fue validado",
                descripcion: "Swietenia macrophylla (Caoba) pasó la revisión científica.",
                fecha: fecha(horasAtras: 2),
                leida: false,
                registroRelacionadoId: "e-002",
                usuarioId: "u-001"
            ),
            Notificacion(
                id: "n-002",
                tipo: .observacion,
                titulo: "Observaciones en tu registro",
                descripcion: "El validador solicitó fotos adicionales del fruto de Bertholletia excelsa.",
                fecha: fecha(horasAtras: 6),
                leida: false,
                registroRelacionadoId: "e-005",
                usuarioId: "u-001"
            ),
            Notificacion(
                id: "n-003",
                tipo: .publicacion,
                titulo: "Registro publicado",
                descripcion: "Cedrela odorata (Cedro) ya está disponible en el catálogo público.",
                fecha: fecha(horasAtras: 26),
                leida: true,
                registroRelacionadoId: "e-001",
                usuarioId: "u-001"
            ),
            Notificacion(
                id: "n-004",
                tipo: .rechazo,
                titulo: "Registro rechazado",
                descripcion: "Faltan datos dasométricos esenciales en uno de tus registros.",
                fecha: fecha(horasAtras: 50),
                leida: true,
                registroRelacionadoId: nil,
                usuarioId: "u-001"
            ),

            // Notificaciones globales (visibles para todos los roles)
            Notificacion(
                id: "n-005",
                tipo: .sistema,
                titulo: "Nueva versión disponible",
                descripcion: "Se publicó la versión 1.2 con mejoras en el módulo de captura de campo.",
                fecha: fecha(horasAtras: 80),
                leida: true,
                registroRelacionadoId: nil,
                usuarioId: nil
            ),

            // u-001 (María) — antiguo
            Notificacion(
                id: "n-006",
                tipo: .validacion,
                titulo: "Tu registro fue validado",
                descripcion: "Dipteryx odorata (Shihuahuaco) pasó la revisión.",
                fecha: fecha(horasAtras: 120),
                leida: true,
                registroRelacionadoId: "e-008",
                usuarioId: "u-001"
            ),

            // u-002 (Lucía, registradora)
            Notificacion(
                id: "n-007",
                tipo: .enRevision,
                titulo: "Tu registro está en revisión",
                descripcion: "Iriartea deltoidea fue enviado al validador científico.",
                fecha: fecha(horasAtras: 18),
                leida: false,
                registroRelacionadoId: "e-012",
                usuarioId: "u-002"
            ),

            // u-004 (Javier, consultor)
            Notificacion(
                id: "n-008",
                tipo: .sistema,
                titulo: "Nuevas especies en el catálogo",
                descripcion: "Se publicaron 3 nuevos registros validados esta semana.",
                fecha: fecha(horasAtras: 30),
                leida: false,
                registroRelacionadoId: nil,
                usuarioId: "u-004"
            ),

            // u-006 (Patricia, administradora) — alertas de gestión
            Notificacion(
                id: "n-009",
                tipo: .sistema,
                titulo: "Cuentas pendientes de revisión",
                descripcion: "Hay 2 cuentas esperando activación.",
                fecha: fecha(horasAtras: 4),
                leida: false,
                registroRelacionadoId: nil,
                usuarioId: "u-006"
            ),
            Notificacion(
                id: "n-010",
                tipo: .sistema,
                titulo: "Registros pendientes de revisión",
                descripcion: "Hay registros enviados que aún no fueron evaluados.",
                fecha: fecha(horasAtras: 9),
                leida: true,
                registroRelacionadoId: nil,
                usuarioId: "u-006"
            )
        ]
    }()
}
