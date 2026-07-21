import Foundation
import Observation

/// Resultado de matching de una especie contra el set actual de filtros.
struct MorfMatch: Identifiable, Hashable {
    let especie: Especie
    let coincidencias: Int
    let total: Int
    var id: String { especie.id }
}

@MainActor
@Observable
final class MorfologicalSearchStore {

    /// Hábito elegido en CS-02. nil = "no estoy seguro" (no filtra por hábito).
    var habito: Habito? = nil

    /// Selecciones por dimensión: id de dimensión → set de labels seleccionados.
    var selecciones: [String: Set<String>] = [:]

    /// Paso actual del wizard de búsqueda. 1 = hábito, 2 = filtros, 3 = resultados.
    var paso: Int = 1

    /// Total de dimensiones con al menos una opción seleccionada.
    var dimensionesActivas: [MorfDimension] {
        MorfDimensions.todas.filter { dim in
            !(selecciones[dim.id] ?? []).isEmpty
        }
    }

    /// Evalúa una lista de especies y devuelve los matches, ordenados por
    /// coincidencias descendentes. Solo incluye especies publicadas / validadas
    /// (lo que ve un consultor) salvo `permitirTodas` = true.
    func evaluar(_ especies: [Especie], permitirTodas: Bool = false) -> [MorfMatch] {
        var base = especies
        if !permitirTodas {
            base = base.filter { $0.estado == .publicado || $0.estado == .validado }
        }
        if let h = habito {
            base = base.filter { $0.habito == h }
        }

        let dims = dimensionesActivas
        let total = dims.count

        // Sin filtros: devuelvo todo el universo con (0, 0).
        if total == 0 {
            return base.map { MorfMatch(especie: $0, coincidencias: 0, total: 0) }
        }

        let matches: [MorfMatch] = base.compactMap { e in
            let texto = textoBuscable(e)
            var hits = 0
            for dim in dims {
                guard let labels = selecciones[dim.id], !labels.isEmpty else { continue }
                let opciones = dim.opciones.filter { labels.contains($0.label) }
                let hit = opciones.contains { opcion in
                    opcion.stems.contains { texto.contains($0.lowercased()) }
                }
                if hit { hits += 1 }
            }
            return hits > 0 ? MorfMatch(especie: e, coincidencias: hits, total: total) : nil
        }
        return matches.sorted { $0.coincidencias > $1.coincidencias }
    }

    func reset() {
        habito = nil
        selecciones = [:]
        paso = 1
    }

    func toggle(dimension: String, opcion: String) {
        var set = selecciones[dimension] ?? []
        if set.contains(opcion) { set.remove(opcion) } else { set.insert(opcion) }
        if set.isEmpty {
            selecciones.removeValue(forKey: dimension)
        } else {
            selecciones[dimension] = set
        }
    }

    func limpiar(dimension: String, opcion: String) {
        var set = selecciones[dimension] ?? []
        set.remove(opcion)
        if set.isEmpty { selecciones.removeValue(forKey: dimension) }
        else { selecciones[dimension] = set }
    }

    private func textoBuscable(_ e: Especie) -> String {
        var partes: [String] = [
            e.descripcion,
            e.nombreLocal,
            e.familia,
            e.nombreCientifico,
            e.ubicacion.tipoHabitat
        ]
        partes.append(contentsOf: e.caracteres.values)
        return partes.joined(separator: " ").lowercased()
    }
}
