import CoreLocation

enum LocationError: LocalizedError {
    case denegado
    case noDisponible

    var errorDescription: String? {
        switch self {
        case .denegado:
            return "Permite el acceso a tu ubicación en Ajustes para usar esta función."
        case .noDisponible:
            return "No se pudo obtener tu ubicación. Inténtalo de nuevo."
        }
    }
}

/// Lectura puntual del GPS con async/await.
/// `CLLocationUpdate.liveUpdates()` pide el permiso automáticamente
/// la primera vez (requiere NSLocationWhenInUseUsageDescription).
enum LocationProvider {

    static func ubicacionActual() async throws -> CLLocationCoordinate2D {
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if update.authorizationDenied || update.authorizationRestricted {
                    throw LocationError.denegado
                }
                if let location = update.location {
                    return location.coordinate
                }
                // Sin fix todavía (p. ej. esperando respuesta al permiso): seguir iterando.
            }
        } catch let error as LocationError {
            throw error
        } catch {
            throw LocationError.noDisponible
        }
        throw LocationError.noDisponible
    }
}
