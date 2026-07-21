import SwiftUI

/// AM-04: hoja modal con cristal para activar un usuario asignándole un rol.
struct ActivarUsuarioSheet: View {

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
            cabecera

            VStack(alignment: .leading, spacing: 10) {
                Text("Asignar rol")
                    .font(.headline)
                Text("Define qué podrá hacer esta persona en FlorAmaz.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(rolesElegibles, id: \.self) { r in
                    rolOption(r)
                }
            }

            Spacer(minLength: 4)

            VStack(spacing: 10) {
                AppButton(enviando ? "Activando…" : "Activar y notificar",
                          systemImage: enviando ? nil : "checkmark.circle.fill",
                          variant: .atencion) {
                    Task {
                        enviando = true
                        await onConfirm(rolSeleccionado)
                        enviando = false
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(enviando)

                AppButton("Cancelar", variant: .terciario) {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.appBackground)
    }

    private var cabecera: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
            ProfileAvatarView(user: usuario)
                .scaleEffect(1.4)
                .frame(height: 60)
                .padding(.top, 8)
            Text(usuario.nombreCompleto)
                .font(.title3.weight(.semibold))
            Text(usuario.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var rolesElegibles: [Rol] {
        // El admin móvil no asigna rol de validador (es solo web).
        Rol.allCases.filter { $0 != .validador }
    }

    private func rolOption(_ r: Rol) -> some View {
        let isOn = rolSeleccionado == r
        return Button {
            rolSeleccionado = r
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icono(r))
                    .font(.system(size: 22))
                    .foregroundStyle(color(r))
                    .frame(width: 42, height: 42)
                    .background(color(r).opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(r.label).font(.subheadline.weight(.semibold))
                    Text(descripcion(r))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isOn ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(isOn ? Color.brand : .secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isOn ? Color.brand.opacity(0.07) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? Color.brand : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func icono(_ r: Rol) -> String {
        switch r {
        case .registrador:   return "pencil.and.list.clipboard"
        case .consultor:     return "books.vertical.fill"
        case .administrador: return "person.badge.shield.checkmark.fill"
        case .validador:     return "checkmark.seal.fill"
        }
    }

    private func color(_ r: Rol) -> Color {
        switch r {
        case .registrador:   return .blue
        case .consultor:     return .teal
        case .administrador: return Color.navigationSelection
        case .validador:     return .purple
        }
    }

    private func descripcion(_ r: Rol) -> String {
        switch r {
        case .registrador:
            return "Captura nuevas especies en campo y envía registros."
        case .consultor:
            return "Explora el catálogo y guarda favoritos."
        case .administrador:
            return "Gestiona cuentas y el catálogo base."
        case .validador:
            return "Solo desde el panel web."
        }
    }
}
