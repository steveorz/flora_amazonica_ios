import Foundation

/// Catálogo central de usuarios mock.
/// Contraseña para todos: `Flora2026`.
enum MockUsuarios {

    static let usuarios: [Usuario] = {
        let now = Date()
        func fecha(diasAtras: Int) -> Date {
            now.addingTimeInterval(-Double(diasAtras) * 86_400)
        }

        return [
            // Registradores
            Usuario(id: "u-001", nombres: "María", apellidos: "Cárdenas",
                    dni: "12345678", email: "registrador@flora.pe",
                    institucion: "Universidad Nacional de la Amazonía Peruana",
                    cargo: "Investigadora botánica",
                    rol: .registrador, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 90), avatarUrl: nil),
            Usuario(id: "u-002", nombres: "Lucía", apellidos: "Mendoza",
                    dni: "23456789", email: "lucia@flora.pe",
                    institucion: "Instituto de Investigaciones de la Amazonía Peruana",
                    cargo: "Botánica de campo",
                    rol: .registrador, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 60), avatarUrl: nil),
            Usuario(id: "u-003", nombres: "Carlos", apellidos: "Ramírez",
                    dni: "34567890", email: "pendiente@flora.pe",
                    institucion: "Universidad Científica del Perú",
                    cargo: "Estudiante de Biología",
                    rol: .registrador, estado: .pendiente,
                    fechaRegistro: fecha(diasAtras: 3), avatarUrl: nil),

            // Consultores
            Usuario(id: "u-004", nombres: "Javier", apellidos: "Ríos",
                    dni: "45678901", email: "consultor@flora.pe",
                    institucion: "IIAP",
                    cargo: "Consultor botánico",
                    rol: .consultor, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 120), avatarUrl: nil),
            Usuario(id: "u-005", nombres: "Andrés", apellidos: "Torres",
                    dni: "56789012", email: "andres@flora.pe",
                    institucion: "Universidad Peruana Cayetano Heredia",
                    cargo: "Investigador asociado",
                    rol: .consultor, estado: .pendiente,
                    fechaRegistro: fecha(diasAtras: 5), avatarUrl: nil),

            // Administradores
            Usuario(id: "u-006", nombres: "Patricia", apellidos: "Vela",
                    dni: "67890123", email: "admin@flora.pe",
                    institucion: "IIAP",
                    cargo: "Administradora del catálogo",
                    rol: .administrador, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 200), avatarUrl: nil),
            Usuario(id: "u-007", nombres: "Sofía", apellidos: "Pinedo",
                    dni: "78901234", email: "sofia@flora.pe",
                    institucion: "Ministerio del Ambiente",
                    cargo: "Coordinadora regional Loreto",
                    rol: .administrador, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 150), avatarUrl: nil),

            // Validador (no usa la app móvil pero existe como cuenta)
            Usuario(id: "u-008", nombres: "Diego", apellidos: "Salinas",
                    dni: "89012345", email: "diego@flora.pe",
                    institucion: "Universidad Nacional Agraria La Molina",
                    cargo: "Validador científico",
                    rol: .validador, estado: .activo,
                    fechaRegistro: fecha(diasAtras: 180), avatarUrl: nil)
        ]
    }()

    static func get(_ id: String) -> Usuario? {
        usuarios.first { $0.id == id }
    }
}
