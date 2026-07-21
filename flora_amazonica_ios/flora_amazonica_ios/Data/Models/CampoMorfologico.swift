import Foundation

struct OpcionMorfologica: Identifiable, Hashable, Sendable {
    let id: String
    let valor: String
    let orden: Int
}

struct CampoMorfologico: Identifiable, Hashable, Sendable {
    var id: String { "\(seccion)-\(nombre)" }
    let seccion: String
    let nombre: String
    let tipoSeleccion: String // "single" | "multiple"
    let tipoCampo: String // "option" | "number" | "text"
    let requerido: Bool
    let orden: Int
    var opciones: [OpcionMorfologica]
}
