import Foundation

let json = """
{"registrar_id":"12c2dac5-2406-4bff-a252-b6059b34d781","scientific_name":"Test Species","family":"Testaceae","habit":"Hierba","country_distribution":["Perú","Brasil"],"height":10.5,"crown_diameter":5,"cap":12,"dap":null,"longitude":-73.2516,"latitude":-3.7437,"morphological_data":{"tallo":"Test"},"status":"en_revision","is_draft":false,"submitted_at":"2026-07-06T10:27:14.189Z","tracking_code":"FAM-2026-00001","validator_id":null,"species_catalog_id":null,"author_name":null,"life_type":null,"description":null,"observation_notes":null,"validated_at":null,"id":"a5ceabdd-dcbe-45e2-8e18-f7b468f497a2","created_at":"2026-07-06T10:27:14.193Z","updated_at":"2026-07-06T10:27:14.193Z"}
"""

private struct SpeciesRecordDTO: Decodable {
    let id: String
    let scientific_name: String
    let author_name: String?
    let family: String
    let common_name: String?
    let habit: String
    let life_type: String?
    let country_distribution: [String]
    let description: String?
    let morphological_data: [String: String]
    let height: Double?
    let crown_diameter: Double?
    let cap: Double?
    let dap: Double?
    let longitude: Double?
    let latitude: Double?
    let status: String
    let tracking_code: String?
    let registrar_id: String
    let submitted_at: Date?
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
    let data = json.data(using: .utf8)!
    let decoded = try decoder.decode(SpeciesRecordDTO.self, from: data)
    print("Success: \(decoded)")
} catch {
    print("Error: \(error)")
}
