import Foundation
import Observation

/// Estado de conectividad simulado.
/// En la app real, se conectaría a `NWPathMonitor`.
/// Aquí el admin puede alternarlo desde Configuración para probar UI.
@MainActor
@Observable
final class ConnectivityStore {

    var online: Bool = true

    /// Cola de envíos pendientes que se acumulan mientras no hay conexión.
    var pendientes: [EnvioPendiente] = []

    func encolar(_ envio: EnvioPendiente) {
        pendientes.append(envio)
    }

    func vaciarCola() {
        pendientes.removeAll()
    }

    func toggle() {
        online.toggle()
    }
}

/// Representa un registro o acción esperando a que vuelva la conexión.
struct EnvioPendiente: Identifiable, Hashable, Sendable {
    let id: String
    var titulo: String
    var detalle: String
    var fecha: Date
}
