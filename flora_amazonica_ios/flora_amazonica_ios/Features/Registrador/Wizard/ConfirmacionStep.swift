import SwiftUI

/// R-14: confirmación de envío. Muestra el código de seguimiento generado.
struct ConfirmacionStep: View {

    @Bindable var store: RegistroWizardStore
    var onCerrar: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            if let res = store.resultado {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.brand)
                    .padding(28)
                    .glassEffect(.regular.tint(Color.brand.opacity(0.18)), in: Circle())

                Text(store.editandoId == nil ? "Registro enviado" : "Cambios guardados")
                    .font(.title.weight(.bold))

                Text("Tu registro está ahora en revisión por el validador científico.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 36)

                VStack(spacing: 6) {
                    Text("Código de seguimiento")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(res.codigoSeguimiento)
                        .font(.title3.monospaced().weight(.semibold))
                        .foregroundStyle(Color.brand)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.brand.opacity(0.12), in: Capsule())
                }

                Spacer()

                AppButton("Listo", variant: .primario, action: onCerrar)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            } else {
                ProgressView()
                Text("Enviando…")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}
