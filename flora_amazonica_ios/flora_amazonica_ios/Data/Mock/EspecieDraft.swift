import Foundation

/// Estado en construcción del wizard de nuevo registro.
/// Codable para guardar como borrador (JSON en UserDefaults).
struct EspecieDraft: Codable, Identifiable, Hashable, Sendable {
    var id: String = UUID().uuidString
    var catalogId: String? = nil
    var nombreCientifico: String = ""
    var autorNombre: String = ""
    var familia: String = ""
    var nombreLocal: String = ""
    var habito: Habito? = nil
    var tipoVida: TipoVida? = nil
    var distribucionPaises: [String] = []
    var descripcion: String = ""
    /// Caracteres morfológicos dinámicos (clave depende del hábito).
    var caracteres: [String: String] = [:]
    var datosDasometricos: DatosDasometricos? = nil
    var ubicacion: Ubicacion? = nil
    /// Marcadores: cuáles tipos de foto fueron capturados (las imágenes en sí viven en memoria).
    var fotosCapturadas: Set<TipoFoto> = []
    /// Último paso visitado (1–7) para retomar el borrador.
    var pasoActual: Int = 1
    var fechaCreacion: Date = .now
    var fechaActualizacion: Date = .now

    /// Inicializa desde una Especie existente (para edición).
    init(from especie: Especie) {
        self.id = especie.id
        self.catalogId = especie.catalogId
        self.nombreCientifico = especie.nombreCientifico
        self.autorNombre = especie.autorNombre
        self.familia = especie.familia
        self.nombreLocal = especie.nombreLocal
        self.habito = especie.habito
        self.tipoVida = especie.tipoVida
        self.distribucionPaises = especie.distribucionPaises
        self.descripcion = especie.descripcion
        self.caracteres = especie.caracteres
        self.datosDasometricos = especie.datosDasometricos
        self.ubicacion = especie.ubicacion
        self.fotosCapturadas = Set(especie.fotos.map(\.tipo))
        self.pasoActual = 1
        self.fechaCreacion = especie.fechaEnvio
        self.fechaActualizacion = .now
    }

    init() {}
}
