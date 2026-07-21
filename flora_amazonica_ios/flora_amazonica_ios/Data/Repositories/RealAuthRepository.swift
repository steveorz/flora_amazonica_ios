import Foundation

class RealAuthRepository: AuthRepository {
    private let apiClient = APIClient.shared
    
    // DTOs for NestJS responses
    private struct LoginResponse: Decodable {
        let access_token: String
        let user: UserDTO
    }

    private struct EmailExistsResponse: Decodable {
        let exists: Bool
    }
    
    private struct UserDTO: Decodable {
        let id: String
        let first_name: String
        let paternal_last_name: String
        let maternal_last_name: String?
        let dni: String?
        let email: String
        let institution: String?
        let position: String?
        let role: String
        let status: String
        let created_at: Date
        let avatar_url: String?
        
        func toUsuario() -> Usuario {
            let apellidos = maternal_last_name != nil ? "\(paternal_last_name) \(maternal_last_name!)" : paternal_last_name
            let rolEnum: Rol = Rol(rawValue: role.lowercased()) ?? .consultor
            let estadoEnum: EstadoUsuario = EstadoUsuario(rawValue: status.lowercased()) ?? .pendiente
            
            return Usuario(
                id: id,
                nombres: first_name,
                apellidos: apellidos,
                dni: dni ?? "",
                email: email,
                institucion: institution ?? "",
                cargo: position ?? "",
                rol: rolEnum,
                estado: estadoEnum,
                fechaRegistro: created_at,
                avatarUrl: avatar_url != nil ? URL(string: avatar_url!) : nil
            )
        }
    }
    
    func emailExists(_ email: String) async throws -> Bool {
        let bodyData = try JSONEncoder().encode(["email": email])
        
        do {
            let response: EmailExistsResponse = try await apiClient.request(endpoint: "/auth/check-email", method: "POST", body: bodyData)
            return response.exists
        } catch {
            return false // Asumimos que no existe si hay un error de red para permitir que intenten crear cuenta
        }
    }

    func login(email: String, password: String) async throws -> (token: String, usuario: Usuario) {
        let body = ["email": email, "password": password]
        let bodyData = try? JSONEncoder().encode(body)
        
        do {
            let response: LoginResponse = try await apiClient.request(endpoint: "/auth/login", method: "POST", body: bodyData)
            return (token: response.access_token, usuario: response.user.toUsuario())
        } catch {
            print("LOGIN EXACT ERROR: \(error)")
            if let apiError = error as? APIError {
                if case .requestFailed(let statusCode, _) = apiError {
                    if statusCode == 403 {
                        let dummyUser = Usuario(id: "", nombres: "Usuario", apellidos: "", dni: "", email: email, institucion: "", cargo: "", rol: .consultor, estado: .pendiente, fechaRegistro: Date(), avatarUrl: nil)
                        throw AuthError.cuentaPendiente(dummyUser)
                    }
                    if statusCode == 401 || statusCode == 404 {
                        throw AuthError.credencialesInvalidas
                    }
                }
                if case .decodingFailed = apiError {
                    print("LOGIN DECODING FAILED")
                }
            }
            throw AuthError.credencialesInvalidas
        }
    }
    
    func validate(token: String) async throws -> Usuario {
        do {
            let userDTO: UserDTO = try await apiClient.request(
                endpoint: "/auth/profile",
                method: "GET",
                token: token,
                timeoutInterval: 3
            )
            return userDTO.toUsuario()
        } catch {
            throw AuthError.sesionInvalida
        }
    }
    
    func register(_ form: RegistroForm) async throws -> Usuario {
        let body: [String: String] = [
            "first_name": form.nombres,
            "paternal_last_name": form.apellidos.components(separatedBy: " ").first ?? form.apellidos,
            "maternal_last_name": form.apellidos.components(separatedBy: " ").dropFirst().joined(separator: " "),
            "email": form.email,
            "password": form.password
        ]
        let bodyData = try? JSONEncoder().encode(body)
        
        do {
            let userDTO: UserDTO = try await apiClient.request(endpoint: "/auth/register", method: "POST", body: bodyData)
            return userDTO.toUsuario()
        } catch {
            throw AuthError.generico
        }
    }
    
    func requestPasswordReset(email: String) async throws {
        // ...
    }
    
    func resetPassword(email: String, nueva: String) async throws {
        // ...
    }
    
    func changePassword(email: String, actual: String, nueva: String) async throws {
        // ...
    }
}
