import Foundation

enum Dasometria {

    /// Diámetro a la altura del pecho (cm), calculado a partir del CAP.
    static func calcularDap(_ cap: Double) -> Double {
        cap / .pi
    }

    /// Devuelve el valor con 1–2 decimales según su magnitud (más decimales para números pequeños).
    static func formato(_ value: Double) -> String {
        let decimales = abs(value) < 10 ? 2 : 1
        return String(format: "%.\(decimales)f", value)
    }

    /// Helper: dap formateado a partir del cap.
    static func dapFormateado(_ cap: Double) -> String {
        formato(calcularDap(cap))
    }
}
