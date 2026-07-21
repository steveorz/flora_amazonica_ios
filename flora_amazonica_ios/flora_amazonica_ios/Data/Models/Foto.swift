import Foundation

struct Foto: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var tipo: TipoFoto
    var url: URL
    var autor: String
    var fecha: Date
    var localData: Data?
}

enum TipoFoto: String, Codable, CaseIterable, Hashable, Sendable {
    case plantaCompleta = "planta_completa"
    case hoja = "hoja"
    case flor = "flor"
    case fruto = "fruto"
    case talloCorteza = "tallo_corteza"

    var label: String {
        switch self {
        case .plantaCompleta: return "Planta completa"
        case .hoja:           return "Hoja"
        case .flor:           return "Flor"
        case .fruto:          return "Fruto"
        case .talloCorteza:   return "Tallo / corteza"
        }
    }
}
