import Foundation

struct DatosDasometricos: Codable, Hashable, Sendable {
    /// Altura total del individuo en metros.
    var altura: Double
    /// Circunferencia a la altura del pecho, en centímetros.
    var cap: Double
    var diamCopaParalelo: Double
    var diamCopaPerpendicular: Double
    var alturaInicioCopa: Double

    /// Diámetro a la altura del pecho (cm), derivado del CAP: dap = cap / π.
    var dap: Double { cap / .pi }
}
