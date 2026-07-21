import SwiftUI

/// C-06: solicitud de recuperación por email.
struct RecoverPasswordView: View {
    var onContinue: (_ email: String) -> Void

    @Environment(SessionStore.self) private var session
    @State private var email = ""
    @State private var loading = false
    @State private var error: String?

    var body: some View {
        ZStack {
            FondoAuthDesenfocado()

            VStack(spacing: 22) {
                Spacer().frame(height: 40)
                VStack(spacing: 8) {
                    Text("Recuperar contraseña")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Te enviaremos un código al correo asociado a tu cuenta.")
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                GlassCard {
                    VStack(spacing: 14) {
                        AppTextField(title: "Email", text: $email, placeholder: "tu@correo.pe")
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)

                        if let error {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        AppButton(loading ? "Enviando…" : "Enviar código", variant: .primario) {
                            submit()
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(loading || email.isEmpty)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationTitle("Recuperar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // Sobre el video desenfocado todo se renderiza en oscuro para que
        // el vidrio y los textos sean legibles.
        .environment(\.colorScheme, .dark)
    }

    private func submit() {
        error = nil
        loading = true
        Task {
            do {
                try await session.requestPasswordReset(email: email)
                loading = false
                onContinue(email)
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

#Preview {
    NavigationStack {
        RecoverPasswordView(onContinue: { _ in })
    }
    .environment(SessionStore(repo: MockAuthRepository()))
}
