import SwiftUI

/// C-10: cambiar contraseña desde el perfil.
struct ChangePasswordView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var actual = ""
    @State private var nueva = ""
    @State private var confirmar = ""
    @State private var loading = false
    @State private var error: String?
    @State private var success = false

    private var puedeEnviar: Bool {
        !actual.isEmpty && nueva.count >= 8 && nueva == confirmar
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                AppTextField(title: "Contraseña actual", text: $actual, kind: .password)
                AppTextField(title: "Nueva contraseña", text: $nueva, kind: .password)
                AppTextField(title: "Confirmar nueva contraseña", text: $confirmar, kind: .password)

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
                if success {
                    Label("Contraseña actualizada", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.blue)
                        .padding(.vertical, 4)
                }

                AppButton(loading ? "Guardando…" : "Guardar cambios", variant: .primario) {
                    submit()
                }
                .frame(maxWidth: .infinity)
                .disabled(loading || !puedeEnviar || success)
                .padding(.top, 4)
            }
            .padding(20)
        }
        .navigationTitle("Cambiar contraseña")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        error = nil
        loading = true
        Task {
            do {
                try await session.changePassword(actual: actual, nueva: nueva)
                loading = false
                success = true
                try? await Task.sleep(for: .milliseconds(800))
                dismiss()
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
