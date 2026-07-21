import Foundation

enum AuthError: LocalizedError, Equatable {
    case credencialesInvalidas
    case cuentaPendiente(Usuario)
    case emailNoEncontrado
    case emailYaRegistrado
    case sesionInvalida
    case generico

    var errorDescription: String? {
        switch self {
        case .credencialesInvalidas: return "Email o contraseña incorrectos."
        case .cuentaPendiente:       return "Tu cuenta aún está pendiente de activación."
        case .emailNoEncontrado:     return "No encontramos una cuenta con ese email."
        case .emailYaRegistrado:     return "Este email ya está registrado."
        case .sesionInvalida:        return "La sesión expiró. Vuelve a iniciar sesión."
        case .generico:              return "Algo salió mal. Inténtalo de nuevo."
        }
    }
}

struct RegistroForm {
    var nombres: String = ""
    var apellidos: String = ""
    var email: String = ""
    var password: String = ""
}

protocol AuthRepository: AnyObject {
    func emailExists(_ email: String) async throws -> Bool
    func login(email: String, password: String) async throws -> (token: String, usuario: Usuario)
    func validate(token: String) async throws -> Usuario
    func register(_ form: RegistroForm) async throws -> Usuario
    func requestPasswordReset(email: String) async throws
    func resetPassword(email: String, nueva: String) async throws
    func changePassword(email: String, actual: String, nueva: String) async throws
}
