import Foundation

/// Catálogo base mock de valores morfológicos editables por el administrador.
/// Refleja las dimensiones usadas en `MorfDimensions`, pero en forma de tabla
/// editable (estilo CRUD).
enum MockValoresMorfologicos {

    static let valores: [ValorMorfologico] = {
        var i = 0
        func v(_ cat: String, _ nombre: String, codigo: String? = nil) -> ValorMorfologico {
            i += 1
            return ValorMorfologico(
                categoria: cat,
                nombre: nombre,
                codigo: codigo ?? slug(cat: cat, nombre: nombre, idx: i),
                orden: i,
                activo: true
            )
        }

        return [
            // Color de flor
            v("Color de flor", "Blanco"),
            v("Color de flor", "Amarillo"),
            v("Color de flor", "Rosa"),
            v("Color de flor", "Rojo"),
            v("Color de flor", "Morado"),
            v("Color de flor", "Verde"),
            v("Color de flor", "Naranja"),
            v("Color de flor", "Crema"),

            // Tipo de inflorescencia
            v("Inflorescencia", "Panícula"),
            v("Inflorescencia", "Racimo"),
            v("Inflorescencia", "Espiga"),
            v("Inflorescencia", "Umbela"),
            v("Inflorescencia", "Cabezuela"),
            v("Inflorescencia", "Solitaria"),

            // Color de fruto
            v("Color de fruto", "Verde"),
            v("Color de fruto", "Amarillo"),
            v("Color de fruto", "Rojo"),
            v("Color de fruto", "Negro"),
            v("Color de fruto", "Marrón"),
            v("Color de fruto", "Naranja"),
            v("Color de fruto", "Morado"),

            // Tipo de fruto
            v("Tipo de fruto", "Seco"),
            v("Tipo de fruto", "Carnoso"),
            v("Tipo de fruto", "Cápsula"),
            v("Tipo de fruto", "Drupa"),
            v("Tipo de fruto", "Legumbre"),
            v("Tipo de fruto", "Sámara"),

            // Tamaño de fruto
            v("Tamaño de fruto", "Pequeño"),
            v("Tamaño de fruto", "Mediano"),
            v("Tamaño de fruto", "Grande"),

            // Tipo de semilla
            v("Semilla", "Alada"),
            v("Semilla", "Fibrosa"),
            v("Semilla", "Aromática"),
            v("Semilla", "Redonda"),

            // Tipo de hoja
            v("Hoja", "Simple"),
            v("Hoja", "Compuesta"),
            v("Hoja", "Pinnada"),
            v("Hoja", "Palmada"),
            v("Hoja", "Opuesta"),
            v("Hoja", "Alterna"),

            // Color del exudado / látex
            v("Exudado", "Transparente"),
            v("Exudado", "Blanco"),
            v("Exudado", "Rojo"),
            v("Exudado", "Amarillo"),

            // Espinas
            v("Espinas", "Presentes")
        ]
    }()

    private static func slug(cat: String, nombre: String, idx: Int) -> String {
        let c = cat.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .folding(options: .diacriticInsensitive, locale: .current)
        let n = nombre.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .folding(options: .diacriticInsensitive, locale: .current)
        return "\(c).\(n).\(idx)"
    }
}
