import Foundation

class RealUsuarioRepository: UsuarioRepository {
    private let apiClient = APIClient.shared
    
    // Using the same UserDTO from RealAuthRepository or defining it here.
    // For simplicity, we'll redefine it here but ideally they share a common DTO.
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
    
    func listar() async throws -> [Usuario] {
        let dtos: [UserDTO] = try await apiClient.request(endpoint: "/usuarios")
        return dtos.map { $0.toUsuario() }
    }
    
    func get(id: String) async throws -> Usuario {
        let dto: UserDTO = try await apiClient.request(endpoint: "/usuarios/\(id)")
        return dto.toUsuario()
    }
    
    func actualizarEstado(id: String, nuevo: EstadoUsuario) async throws {
        let body = ["status": nuevo.rawValue]
        let bodyData = try? JSONEncoder().encode(body)
        let _ : [String: String]? = try? await apiClient.request(endpoint: "/usuarios/\(id)/estado", method: "PATCH", body: bodyData)
    }
    
    func actualizarRol(id: String, nuevo: Rol) async throws {
        let body = ["role": nuevo.rawValue]
        let bodyData = try? JSONEncoder().encode(body)
        let _ : [String: String]? = try? await apiClient.request(endpoint: "/usuarios/\(id)/rol", method: "PATCH", body: bodyData)
    }
}
