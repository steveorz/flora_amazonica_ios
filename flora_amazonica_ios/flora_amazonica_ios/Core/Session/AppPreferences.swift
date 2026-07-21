import Foundation
import Observation
import SwiftUI

/// Preferencias persistidas del usuario (tema, notificaciones, idioma).
@MainActor
@Observable
final class AppPreferences {

    enum Tema: String, CaseIterable, Identifiable, Sendable {
        case sistema, claro, oscuro
        var id: String { rawValue }
        var label: String {
            switch self {
            case .sistema: return "Sistema"
            case .claro:   return "Claro"
            case .oscuro:  return "Oscuro"
            }
        }
    }

    enum Idioma: String, CaseIterable, Identifiable, Sendable {
        case espanol = "es"
        case ingles  = "en"
        var id: String { rawValue }
        var label: String {
            switch self {
            case .espanol: return "Español"
            case .ingles:  return "Inglés"
            }
        }
    }

    var tema: Tema {
        didSet { UserDefaults.standard.set(tema.rawValue, forKey: Keys.tema) }
    }

    var idioma: Idioma {
        didSet { UserDefaults.standard.set(idioma.rawValue, forKey: Keys.idioma) }
    }

    var notificacionesActivas: Bool {
        didSet { UserDefaults.standard.set(notificacionesActivas, forKey: Keys.notif) }
    }

    init() {
        let d = UserDefaults.standard
        self.tema = Tema(rawValue: d.string(forKey: Keys.tema) ?? "") ?? .sistema
        self.idioma = Idioma(rawValue: d.string(forKey: Keys.idioma) ?? "") ?? .espanol
        self.notificacionesActivas = (d.object(forKey: Keys.notif) as? Bool) ?? true
    }

    var colorScheme: ColorScheme? {
        switch tema {
        case .sistema: return nil
        case .claro:   return .light
        case .oscuro:  return .dark
        }
    }

    /// "Limpia caché": resetea borradores, favoritos en memoria y preferencias volátiles.
    /// En la app real, también limpiaría imágenes en disco.
    func limpiarCache() {
        UserDefaults.standard.removeObject(forKey: "registrador.drafts")
        UserDefaults.standard.removeObject(forKey: "favoritos.ids")
    }

    private enum Keys {
        static let tema = "app.tema"
        static let idioma = "app.idioma"
        static let notif = "app.notif"
    }
}
