import Foundation

@MainActor
final class MockAuthRepository: AuthRepository {

    private var users: [String: (password: String, usuario: Usuario)] = [:]

    init() {
        for u in MockUsuarios.usuarios {
            users[u.email.lowercased()] = (password: "Flora2026", usuario: u)
        }
    }

    func emailExists(_ email: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(300))
        return users[email.lowercased()] != nil
    }

    func login(email: String, password: String) async throws -> (token: String, usuario: Usuario) {
        try await Task.sleep(for: .milliseconds(600))
        let key = email.lowercased()
        guard let entry = users[key] else { throw AuthError.credencialesInvalidas }
        guard entry.password == password else { throw AuthError.credencialesInvalidas }
        if entry.usuario.estado == .pendiente {
            throw AuthError.cuentaPendiente(entry.usuario)
        }
        let token = "mock-\(entry.usuario.email.lowercased())"
        return (token, entry.usuario)
    }


    func validate(token: String) async throws -> Usuario {
        try await Task.sleep(for: .milliseconds(250))
        guard token.hasPrefix("mock-") else { throw AuthError.sesionInvalida }
        let email = String(token.dropFirst("mock-".count))
        guard let entry = users[email.lowercased()] else { throw AuthError.sesionInvalida }
        guard entry.usuario.estado == .activo else { throw AuthError.sesionInvalida }
        return entry.usuario
    }

    func register(_ form: RegistroForm) async throws -> Usuario {
        try await Task.sleep(for: .milliseconds(700))
        let key = form.email.lowercased()
        if users[key] != nil { throw AuthError.emailYaRegistrado }
        let nuevo = Usuario(
            id: "u-\(UUID().uuidString.prefix(8))",
            nombres: form.nombres,
            apellidos: form.apellidos,
            dni: "",
            email: form.email,
            institucion: "",
            cargo: "",
            rol: .registrador,
            estado: .pendiente,
            fechaRegistro: Date(),
            avatarUrl: nil
        )
        users[key] = (password: form.password, usuario: nuevo)
        return nuevo
    }

    func requestPasswordReset(email: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        guard users[email.lowercased()] != nil else { throw AuthError.emailNoEncontrado }
    }

    func resetPassword(email: String, nueva: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        let key = email.lowercased()
        guard var entry = users[key] else { throw AuthError.emailNoEncontrado }
        entry.password = nueva
        users[key] = entry
    }

    func changePassword(email: String, actual: String, nueva: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        let key = email.lowercased()
        guard var entry = users[key], entry.password == actual else {
            throw AuthError.credencialesInvalidas
        }
        entry.password = nueva
        users[key] = entry
    }
}
