import SwiftUI

/// C-05: confirmación de cuenta esperando activación.
struct AccountCreatedView: View {
    var onBackToLogin: () -> Void

    var body: some View {
        ZStack {
            FondoAuthDesenfocado()

            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "envelope.badge.shield.half.filled.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .padding(28)
                    .glassEffect(.regular.tint(.white.opacity(0.2)), in: Circle())

                Text("Cuenta creada")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text("Tu cuenta está esperando la activación de un administrador. Recibirás un correo cuando esté lista.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 32)

                Spacer()

                AppButton("Volver al inicio de sesión", variant: .primario, action: onBackToLogin)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // Sobre el video desenfocado todo se renderiza en oscuro para que
        // el vidrio y los textos sean legibles.
        .environment(\.colorScheme, .dark)
    }
}
