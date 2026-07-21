import Foundation

enum TipoVida: String, Codable, CaseIterable, Hashable, Sendable {
    case terrestre
    case epifita
    case parasita

    var label: String {
        switch self {
        case .terrestre: return "Terrestre"
        case .epifita:   return "Epífita"
        case .parasita:  return "Parásita"
        }
    }
}
