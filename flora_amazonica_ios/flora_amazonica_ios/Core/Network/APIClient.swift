import Foundation

struct APIErrorResponse: Decodable {
    var message: String?
    let error: String?
    let statusCode: Int?
    
    private enum CodingKeys: String, CodingKey {
        case message, error, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        
        if let msgString = try? container.decode(String.self, forKey: .message) {
            message = msgString
        } else if let msgArray = try? container.decode([String].self, forKey: .message) {
            message = msgArray.joined(separator: ", ")
        } else {
            message = nil
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int, String?)
    case decodingFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .requestFailed(let code, let msg):
            return msg ?? "Error del servidor (\(code))"
        case .invalidURL: return "URL inválida"
        case .decodingFailed: return "Error decodificando respuesta"
        case .unknown: return "Error desconocido"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    let baseURL = "https://floraamazonica-backendapi-production.up.railway.app/api/v1"
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil,
        timeoutInterval: TimeInterval = 10
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let finalToken = token ?? KeychainStore.load()
        if let t = finalToken {
            request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            var errorMessage: String? = nil
            if let errorObj = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                errorMessage = errorObj.message
            } else if let errorString = String(data: data, encoding: .utf8) {
                print("API ERROR RESPONSE (\(statusCode)): \(errorString)")
            }
            throw APIError.requestFailed(statusCode, errorMessage)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                
                let fallbackFormatter = ISO8601DateFormatter()
                if let date = fallbackFormatter.date(from: dateStr) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateStr)")
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingFailed
        }
    }

    func uploadMultipart<T: Decodable>(
        endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        parameters: [String: String],
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let finalToken = token ?? KeychainStore.load()
        if let t = finalToken {
            request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.requestFailed(statusCode, nil)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
