import Foundation
import Observation

/// Estado de sesión global. Sobrevive a recargas mientras haya token válido en Keychain.
@MainActor
@Observable
final class SessionStore {

    var usuario: Usuario?
    var token: String?

    private let repo: AuthRepository

    init() {
        self.repo = RealAuthRepository()
    }

    init(repo: AuthRepository) {
        self.repo = repo
    }

    var rol: Rol? { usuario?.rol }
    var isAutenticado: Bool { usuario != nil && usuario?.estado == .activo }
    var isPendiente: Bool { usuario?.estado == .pendiente }

    func emailExists(_ email: String) async -> Result<Bool, AuthError> {
        do {
            return .success(try await repo.emailExists(email))
        } catch let e as AuthError {
            return .failure(e)
        } catch {
            return .failure(.generico)
        }
    }

    /// Intenta restaurar la sesión desde el token guardado en Keychain.
    func restoreSession() async {
        guard let saved = KeychainStore.load() else { return }
        do {
            let u = try await repo.validate(token: saved)
            self.token = saved
            self.usuario = u
        } catch {
            KeychainStore.delete()
        }
    }

    /// Devuelve nil en éxito o el AuthError a mostrar.
    /// Si el usuario está pendiente, NO devuelve error: setea `usuario` (sin token)
    /// para que RootView muestre C-08.
    @discardableResult
    func login(email: String, password: String) async -> AuthError? {
        do {
            let (t, u) = try await repo.login(email: email, password: password)
            KeychainStore.save(t)
            self.token = t
            self.usuario = u
            return nil
        } catch let e as AuthError {
            if case .cuentaPendiente(let u) = e {
                self.usuario = u
                self.token = nil
                return nil
            }
            return e
        } catch {
            return .generico
        }
    }
    func logout() {
        KeychainStore.delete()
        self.token = nil
        self.usuario = nil
    }

    func register(_ form: RegistroForm) async throws -> Usuario {
        try await repo.register(form)
    }

    func requestPasswordReset(email: String) async throws {
        try await repo.requestPasswordReset(email: email)
    }

    func resetPassword(email: String, nueva: String) async throws {
        try await repo.resetPassword(email: email, nueva: nueva)
    }

    func changePassword(actual: String, nueva: String) async throws {
        guard let email = usuario?.email else { throw AuthError.sesionInvalida }
        try await repo.changePassword(email: email, actual: actual, nueva: nueva)
    }
}
