import SwiftUI

extension Color {
    /// Fondo global de pantallas: crema (#F8F9F2) en claro, fondo del sistema en oscuro.
    static let appBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? .systemBackground
            : UIColor(red: 248/255, green: 249/255, blue: 242/255, alpha: 1)
    })

    /// Color para títulos grandes (#1B4332).
    static let heading = Color(red: 27/255, green: 67/255, blue: 50/255)

    /// Color neutral principal para superficies y acciones fuera de la navegación.
    /// Se invierte en modo oscuro (negro → blanco) para mantener el contraste.
    static let brand = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : .black
    })

    /// Contenido pintado ENCIMA de un relleno `brand` (texto/íconos sobre la marca).
    static let onBrand = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : .white
    })

    /// Verde reservado solo para el botón seleccionado en la barra de navegación (#40916C).
    static let navigationSelection = Color(red: 64/255, green: 145/255, blue: 108/255)
}
