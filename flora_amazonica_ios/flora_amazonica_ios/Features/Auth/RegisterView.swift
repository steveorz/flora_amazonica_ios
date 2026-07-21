import SwiftUI

/// C-04: registro de cuenta.
struct RegisterView: View {
    var onCreated: () -> Void

    @Environment(SessionStore.self) private var session
    @State private var form = RegistroForm()
    @State private var confirmPassword = ""
    @State private var aceptaTerminos = false
    @State private var loading = false
    @State private var error: String?

    private var emailValido: Bool {
        let r = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return form.email.range(of: r, options: [.regularExpression, .caseInsensitive]) != nil
    }
    private var passwordsCoinciden: Bool {
        !form.password.isEmpty && form.password == confirmPassword
    }
    private var puedeEnviar: Bool {
        !form.nombres.isEmpty && !form.apellidos.isEmpty && emailValido &&
        form.password.count >= 8 && passwordsCoinciden && aceptaTerminos
    }

    init(initialEmail: String = "", onCreated: @escaping () -> Void) {
        self.onCreated = onCreated

        var initialForm = RegistroForm()
        initialForm.email = initialEmail
        _form = State(initialValue: initialForm)
    }

    var body: some View {
        ZStack {
            FondoAuthDesenfocado()

            ScrollView {
                VStack(spacing: 18) {
                    Text("Crea tu cuenta")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    GlassCard {
                        VStack(spacing: 14) {
                            AppTextField(title: "Nombres", text: $form.nombres)
                            AppTextField(title: "Apellidos", text: $form.apellidos)
                            AppTextField(title: "Email", text: $form.email, placeholder: "tu@correo.pe")
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)

                            VStack(alignment: .leading, spacing: 6) {
                                AppTextField(title: "Contraseña", text: $form.password, kind: .password)
                                PasswordStrengthIndicator(password: form.password)
                            }
                            AppTextField(title: "Confirmar contraseña", text: $confirmPassword, kind: .password)

                            if !confirmPassword.isEmpty && !passwordsCoinciden {
                                Text("Las contraseñas no coinciden")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                aceptaTerminos.toggle()
                            } label: {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: aceptaTerminos ? "checkmark.square.fill" : "square")
                                        .foregroundStyle(aceptaTerminos ? Color.brand : .secondary)
                                        .font(.system(size: 20))
                                    Text("Acepto los términos y condiciones")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if let error {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            AppButton(loading ? "Creando…" : "Crear cuenta", variant: .primario) {
                                submit()
                            }
                            .frame(maxWidth: .infinity)
                            .disabled(loading || !puedeEnviar)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Crear cuenta")
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
                _ = try await session.register(form)
                loading = false
                onCreated()
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
        RegisterView(onCreated: {})
    }
    .environment(SessionStore(repo: MockAuthRepository()))
}

private struct PasswordStrengthIndicator: View {
    let password: String

    private var score: Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { s += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { s += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { s += 1 }
        return s
    }

    private var color: Color {
        switch score {
        case 0...1: return .red
        case 2:     return .orange
        case 3:     return .yellow
        default:    return .blue
        }
    }

    private var label: String {
        switch score {
        case 0...1: return "Débil"
        case 2:     return "Aceptable"
        case 3:     return "Buena"
        default:    return "Fuerte"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < score ? color : Color(.tertiarySystemBackground))
                        .frame(height: 5)
                }
            }
            if !password.isEmpty {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
