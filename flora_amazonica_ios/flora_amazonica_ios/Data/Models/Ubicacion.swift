import Foundation

struct Ubicacion: Codable, Hashable, Sendable {
    var lat: Double
    var long: Double
    var referencia: String
    /// Metros sobre el nivel del mar.
    var altitud: Double
    var tipoHabitat: String
}
