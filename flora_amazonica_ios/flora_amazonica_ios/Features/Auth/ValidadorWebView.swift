import SwiftUI

/// La ven las cuentas con rol Validador: ese rol trabaja desde la plataforma web,
/// así que al entrar se abre el navegador automáticamente.
struct ValidadorWebView: View {
    let usuario: Usuario
    var onBack: () -> Void

    @Environment(\.openURL) private var openURL

    /// TODO: reemplazar por la URL oficial de la plataforma web cuando esté lista.
    static let webURL = URL(string: "https://flora-amazonica.com/")!

    var body: some View {
        ZStack {
            // Pantalla diseñada en negro con texto blanco: no sigue el tema.
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.4)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "safari.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .padding(28)
                    .glassEffect(.regular.tint(.white.opacity(0.2)), in: Circle())

                Text("Plataforma web de validación")
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text("Hola \(usuario.nombres), las cuentas de Validador se usan desde la plataforma web. Te estamos llevando al navegador.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    AppButton("Abrir la plataforma web", variant: .primario) {
                        openURL(Self.webURL)
                    }
                    AppButton("Volver al inicio de sesión", variant: .secundario, action: onBack)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            openURL(Self.webURL)
        }
    }
}
