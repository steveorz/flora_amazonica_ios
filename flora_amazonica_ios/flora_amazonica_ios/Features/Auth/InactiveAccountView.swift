import SwiftUI

/// C-08: la ven los usuarios cuya cuenta aún no fue activada.
struct InactiveAccountView: View {
    let usuario: Usuario
    var onBack: () -> Void

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
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .padding(28)
                    .glassEffect(.regular.tint(.white.opacity(0.2)), in: Circle())

                Text("Cuenta pendiente")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text("Hola \(usuario.nombres), tu cuenta aún espera la activación de un administrador. Te avisaremos por correo cuando esté lista.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 32)

                Spacer()

                AppButton("Volver al inicio de sesión", variant: .primario, action: onBack)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
    }
}
