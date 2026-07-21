import Foundation

/// Catálogo dinámico de valores para caracteres morfológicos
/// (ej.: forma de hoja, tipo de inflorescencia, color de corteza, etc.).
struct ValorMorfologico: Identifiable, Codable, Hashable, Sendable {
    var id: String { codigo }
    var categoria: String
    var nombre: String
    var codigo: String
    var orden: Int
    var activo: Bool
}
