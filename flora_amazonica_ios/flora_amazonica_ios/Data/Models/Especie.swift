import Foundation

struct Especie: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var catalogId: String?
    var nombreCientifico: String
    var autorNombre: String
    var familia: String
    var nombreLocal: String
    var habito: Habito
    var tipoVida: TipoVida
    var distribucionPaises: [String]
    var descripcion: String
    /// Diccionario dinámico de caracteres morfológicos (depende del hábito).
    var caracteres: [String: String]
    var datosDasometricos: DatosDasometricos?
    var ubicacion: Ubicacion
    var fotos: [Foto]
    var estado: EstadoRegistro
    var codigoSeguimiento: String
    var registradorId: String
    var fechaEnvio: Date
    var historialEstados: [HistorialEstado]
}

struct HistorialEstado: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var estado: EstadoRegistro
    var fecha: Date
    var usuarioId: String
    var comentario: String?
}
