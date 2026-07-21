import SwiftUI

/// AM-05: hoja modal para cambiar el rol de un usuario ya activo.
struct CambiarRolSheet: View {

    let usuario: Usuario
    let onConfirm: (Rol) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rolSeleccionado: Rol
    @State private var enviando = false

    init(usuario: Usuario, onConfirm: @escaping (Rol) async -> Void) {
        self.usuario = usuario
        self.onConfirm = onConfirm
        _rolSeleccionado = State(initialValue: usuario.rol)
    }

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text("Cambiar rol")
                    .font(.title3.weight(.semibold))
                Text("Rol actual: \(usuario.rol.label)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Picker("Nuevo rol", selection: $rolSeleccionado) {
                ForEach(rolesElegibles, id: \.self) { r in
                    Text(r.label).tag(r)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 22)

            Text(descripcion(rolSeleccionado))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)

            Spacer(minLength: 4)

            VStack(spacing: 10) {
                AppButton(enviando ? "Guardando…" : "Guardar y notificar",
                          systemImage: enviando ? nil : "checkmark.circle.fill",
                          variant: .atencion) {
                    Task {
                        enviando = true
                        await onConfirm(rolSeleccionado)
                        enviando = false
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(rolSeleccionado == usuario.rol || enviando)

                AppButton("Cancelar", variant: .terciario) {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
        .background(Color.appBackground)
    }

    private var rolesElegibles: [Rol] {
        Rol.allCases.filter { $0 != .validador }
    }

    private func descripcion(_ r: Rol) -> String {
        switch r {
        case .registrador:
            return "Podrá registrar nuevas especies desde la app móvil."
        case .consultor:
            return "Solo podrá consultar el catálogo y guardar favoritos."
        case .administrador:
            return "Tendrá control sobre cuentas y el catálogo base."
        case .validador:
            return "Solo desde el panel web."
        }
    }
}
