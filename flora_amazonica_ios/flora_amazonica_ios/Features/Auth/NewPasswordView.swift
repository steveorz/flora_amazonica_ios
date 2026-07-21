import SwiftUI

/// C-07: definición de nueva contraseña.
struct NewPasswordView: View {
    let email: String
    var onDone: () -> Void

    @Environment(SessionStore.self) private var session
    @State private var nueva = ""
    @State private var confirmar = ""
    @State private var loading = false
    @State private var error: String?
    @State private var success = false

    private var puedeEnviar: Bool { nueva.count >= 8 && nueva == confirmar }

    var body: some View {
        ZStack {
            FondoAuthDesenfocado()

            VStack(spacing: 22) {
                Spacer().frame(height: 40)

                if success {
                    successView
                } else {
                    formView
                }

                Spacer()
            }
        }
        .navigationTitle("Nueva contraseña")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(success)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // Sobre el video desenfocado todo se renderiza en oscuro para que
        // el vidrio y los textos sean legibles.
        .environment(\.colorScheme, .dark)
    }

    @ViewBuilder
    private var formView: some View {
        VStack(spacing: 8) {
            Text("Define tu nueva contraseña")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Para \(email)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }

        GlassCard {
            VStack(spacing: 14) {
                AppTextField(title: "Nueva contraseña", text: $nueva, kind: .password)
                AppTextField(title: "Confirmar contraseña", text: $confirmar, kind: .password)

                if !confirmar.isEmpty && nueva != confirmar {
                    Text("Las contraseñas no coinciden")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                AppButton(loading ? "Guardando…" : "Guardar contraseña", variant: .primario) {
                    submit()
                }
                .frame(maxWidth: .infinity)
                .disabled(loading || !puedeEnviar)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var successView: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)
                .padding(24)
                .glassEffect(.regular.tint(.white.opacity(0.22)), in: Circle())
            Text("Contraseña actualizada")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Ya puedes iniciar sesión con tu nueva contraseña.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AppButton("Volver al inicio de sesión", variant: .primario, action: onDone)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 8)
        }
    }

    private func submit() {
        error = nil
        loading = true
        Task {
            do {
                try await session.resetPassword(email: email, nueva: nueva)
                loading = false
                success = true
            } catch let e as AuthError {
                error = e.errorDescription
                loading = false
            } catch {
                self.error = AuthError.generico.errorDescription
                loading = false
            }
        }
    }
}
