import Foundation

/// Dimensiones y opciones para la búsqueda morfológica.
/// Cada opción tiene varios `stems` (raíces) que se buscan como substrings
/// en los caracteres / descripción de la especie. Esto permite matchear
/// variaciones de género/número del español ("amarillo" / "amarillenta", etc.).
struct MorfDimension: Identifiable, Hashable, Sendable {
    let id: String
    let categoria: String
    let titulo: String
    let opciones: [MorfOpcion]
}

struct MorfOpcion: Identifiable, Hashable, Sendable {
    var id: String { label }
    let label: String
    let stems: [String]
}

enum MorfDimensions {

    static let categorias = ["Florales", "Fruto", "Semilla", "Vegetativo"]

    static let todas: [MorfDimension] = [
        // ─── Florales ───
        .init(id: "color_flor", categoria: "Florales", titulo: "Color de flor", opciones: [
            .init(label: "Blanco",   stems: ["blanc"]),
            .init(label: "Amarillo", stems: ["amarill"]),
            .init(label: "Rosa",     stems: ["rosa", "rosad"]),
            .init(label: "Rojo",     stems: ["roj"]),
            .init(label: "Morado",   stems: ["morad", "violet"]),
            .init(label: "Verde",    stems: ["verd"]),
            .init(label: "Naranja",  stems: ["naranj"]),
            .init(label: "Crema",    stems: ["crem"])
        ]),
        .init(id: "inflorescencia", categoria: "Florales", titulo: "Inflorescencia", opciones: [
            .init(label: "Panícula",  stems: ["panícul", "paníc"]),
            .init(label: "Racimo",    stems: ["racim"]),
            .init(label: "Espiga",    stems: ["espig"]),
            .init(label: "Umbela",    stems: ["umbel"]),
            .init(label: "Cabezuela", stems: ["cabezuel"]),
            .init(label: "Solitaria", stems: ["solitar"])
        ]),

        // ─── Fruto ───
        .init(id: "color_fruto", categoria: "Fruto", titulo: "Color de fruto", opciones: [
            .init(label: "Verde",    stems: ["verd"]),
            .init(label: "Amarillo", stems: ["amarill"]),
            .init(label: "Rojo",     stems: ["roj"]),
            .init(label: "Negro",    stems: ["negr", "oscur"]),
            .init(label: "Marrón",   stems: ["marró", "pard", "café"]),
            .init(label: "Naranja",  stems: ["naranj"]),
            .init(label: "Morado",   stems: ["morad", "violet"])
        ]),
        .init(id: "tipo_fruto", categoria: "Fruto", titulo: "Tipo de fruto", opciones: [
            .init(label: "Seco",     stems: ["cápsul", "legumbr", "sámar", "leñoso", "leñosa"]),
            .init(label: "Carnoso",  stems: ["drup", "carnos", "baya"]),
            .init(label: "Cápsula",  stems: ["cápsul"]),
            .init(label: "Drupa",    stems: ["drup"]),
            .init(label: "Legumbre", stems: ["legumbr"]),
            .init(label: "Sámara",   stems: ["sámar"])
        ]),
        .init(id: "tamano_fruto", categoria: "Fruto", titulo: "Tamaño de fruto", opciones: [
            .init(label: "Pequeño", stems: ["pequeñ"]),
            .init(label: "Mediano", stems: ["median"]),
            .init(label: "Grande",  stems: ["grand"])
        ]),

        // ─── Semilla ───
        .init(id: "tipo_semilla", categoria: "Semilla", titulo: "Tipo de semilla", opciones: [
            .init(label: "Alada",      stems: ["alad", " ala"]),
            .init(label: "Fibrosa",    stems: ["fibr"]),
            .init(label: "Aromática",  stems: ["aromát"]),
            .init(label: "Redonda",    stems: ["redond", "globos", "esféric"])
        ]),

        // ─── Vegetativo ───
        .init(id: "tipo_hoja", categoria: "Vegetativo", titulo: "Tipo de hoja", opciones: [
            .init(label: "Simple",    stems: ["simple"]),
            .init(label: "Compuesta", stems: ["compuesta", "pinnad", "palmad"]),
            .init(label: "Pinnada",   stems: ["pinnad"]),
            .init(label: "Palmada",   stems: ["palmad", "palmar"]),
            .init(label: "Opuesta",   stems: ["opuest"]),
            .init(label: "Alterna",   stems: ["altern"])
        ]),
        .init(id: "exudado", categoria: "Vegetativo", titulo: "Color de exudado / látex", opciones: [
            .init(label: "Transparente", stems: ["transparent", "incoloro"]),
            .init(label: "Blanco",       stems: ["látex blanc", "savia blanc"]),
            .init(label: "Rojo",         stems: ["látex roj", "savia roj", "sangre"]),
            .init(label: "Amarillo",     stems: ["látex amarill", "resina amarill"])
        ]),
        .init(id: "espinas", categoria: "Vegetativo", titulo: "Espinas / aguijones", opciones: [
            .init(label: "Presentes", stems: ["espin", "aguijo"])
        ])
    ]

    static func dimensiones(de categoria: String) -> [MorfDimension] {
        todas.filter { $0.categoria == categoria }
    }
}
