import SwiftUI

enum Habito: String, Codable, CaseIterable, Hashable, Sendable {
    case arbol
    case palmera
    case arbusto
    case liana
    case hierba

    var label: String {
        switch self {
        case .arbol:   return "Árbol"
        case .palmera: return "Palmera"
        case .arbusto: return "Arbusto"
        case .liana:   return "Liana"
        case .hierba:  return "Hierba"
        }
    }

    var color: Color {
        switch self {
        case .arbol:   return .blue
        case .palmera: return .yellow
        case .arbusto: return .mint
        case .liana:   return .brown
        case .hierba:  return .teal
        }
    }

    /// Imageset del asset catalog con la foto representativa de la categoría.
    var categoryImage: String {
        switch self {
        case .arbol:   return "arbol_category"
        case .palmera: return "palmera_category"
        case .arbusto: return "arbusto_category"
        case .liana:   return "liana_category"
        case .hierba:  return "hierba_category"
        }
    }

}
