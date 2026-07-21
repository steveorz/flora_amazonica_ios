import SwiftUI

/// AM-03: detalle de usuario con datos, actividad y botones según estado.
struct UsuarioDetalleView: View {

    let usuarioId: String

    @Environment(UsuarioService.self) private var usuarios
    @Environment(EspecieService.self) private var especies
    @Environment(NotificacionService.self) private var notificaciones
    @Environment(\.dismiss) private var dismiss

    @State private var sheetActivar = false
    @State private var sheetCambiarRol = false
    @State private var confirmDesactivar = false
    @State private var confirmReactivar = false
    @State private var toast: ToastInfo?

    private var usuario: Usuario? {
        usuarios.usuarios.first { $0.id == usuarioId }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let u = usuario {
                    encabezado(u)
                    datos(u)
                    actividad(u)
                    acciones(u)
                } else if usuarios.loading {
                    LoadingSkeleton(cornerRadius: 12).frame(height: 220)
                } else {
                    ErrorState(kind: .servidor) { dismiss() }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground)
        .navigationTitle("Usuario")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $sheetActivar) {
            if let u = usuario {
                ActivarUsuarioSheet(usuario: u) { rol in
                    await accionActivar(u: u, rol: rol)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $sheetCambiarRol) {
            if let u = usuario {
                CambiarRolSheet(usuario: u) { rol in
                    await accionCambiarRol(u: u, rol: rol)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .confirmationDialog(
            "¿Desactivar a este usuario?",
            isPresented: $confirmDesactivar,
            titleVisibility: .visible
        ) {
            Button("Desactivar", role: .destructive) {
                Task { await accionDesactivar() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("No podrá iniciar sesión hasta que lo reactives.")
        }
        .confirmationDialog(
            "¿Reactivar a este usuario?",
            isPresented: $confirmReactivar,
            titleVisibility: .visible
        ) {
            Button("Reactivar") {
                Task { await accionReactivar() }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .overlay(alignment: .top) {
            if let t = toast {
                AppToast(kind: t.kind, message: t.message)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(for: .seconds(2.2))
                        toast = nil
                    }
            }
        }
    }

    // MARK: - Sections

    private func encabezado(_ u: Usuario) -> some View {
        VStack(spacing: 10) {
            Circle()
                .fill(LinearGradient(
                    colors: [Color.brand, Color.brand.opacity(0.65)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 92, height: 92)
                .overlay(
                    Text(iniciales(u))
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.onBrand)
                )
            Text(u.nombreCompleto)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(u.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                EstadoUsuarioBadge(estado: u.estado)
                Text(u.rol.label)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundStyle(.primary)
                    .glassEffect(.regular, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func datos(_ u: Usuario) -> some View {
        VStack(spacing: 0) {
            row("DNI", u.dni)
            divider
            row("Institución", u.institucion)
            divider
            row("Cargo", u.cargo)
            divider
            row("Registro", u.fechaRegistro.formatted(date: .abbreviated, time: .omitted))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func actividad(_ u: Usuario) -> some View {
        let registros = especies.registrosDe(usuarioId: u.id)
        VStack(alignment: .leading, spacing: 8) {
            Text("Actividad")
                .font(.headline)
            if u.rol == .registrador {
                HStack(spacing: 10) {
                    miniStat(titulo: "Registros", valor: registros.count, icono: "leaf.fill", color: .blue)
                    miniStat(titulo: "Publicados",
                             valor: registros.filter { $0.estado == .publicado }.count,
                             icono: "globe.americas", color: Color.navigationSelection)
                    miniStat(titulo: "En revisión",
                             valor: registros.filter { $0.estado == .enRevision }.count,
                             icono: "magnifyingglass", color: .indigo)
                }
                if registros.isEmpty {
                    Text("Aún no ha enviado registros.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Sin actividad de registros para este rol.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func acciones(_ u: Usuario) -> some View {
        VStack(spacing: 10) {
            switch u.estado {
            case .pendiente:
                AppButton("Activar y asignar rol", systemImage: "checkmark.circle.fill",
                          variant: .atencion) {
                    sheetActivar = true
                }
                .frame(maxWidth: .infinity)
                AppButton("Rechazar cuenta", systemImage: "xmark.circle",
                          variant: .destructivo) {
                    confirmDesactivar = true
                }
                .frame(maxWidth: .infinity)

            case .activo:
                AppButton("Cambiar rol", systemImage: "person.2.crop.square.stack",
                          variant: .primario) {
                    sheetCambiarRol = true
                }
                .frame(maxWidth: .infinity)
                AppButton("Desactivar", systemImage: "person.fill.xmark",
                          variant: .destructivo) {
                    confirmDesactivar = true
                }
                .frame(maxWidth: .infinity)

            case .inactivo:
                AppButton("Reactivar cuenta", systemImage: "arrow.uturn.up.circle.fill",
                          variant: .atencion) {
                    confirmReactivar = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Action handlers

    private func accionActivar(u: Usuario, rol: Rol) async {
        do {
            if rol != u.rol {
                try await usuarios.actualizarRol(id: u.id, nuevo: rol)
            }
            try await usuarios.actualizarEstado(id: u.id, nuevo: .activo)
            await notificaciones.notificarCuentaActivada(usuarioId: u.id, rol: rol)
            sheetActivar = false
            toast = ToastInfo(kind: .exito, message: "Cuenta activada y notificada.")
        } catch {
            toast = ToastInfo(kind: .error, message: "No se pudo activar la cuenta.")
        }
    }

    private func accionCambiarRol(u: Usuario, rol: Rol) async {
        guard rol != u.rol else { sheetCambiarRol = false; return }
        do {
            try await usuarios.actualizarRol(id: u.id, nuevo: rol)
            await notificaciones.notificarRolActualizado(usuarioId: u.id, nuevoRol: rol)
            sheetCambiarRol = false
            toast = ToastInfo(kind: .exito, message: "Rol actualizado y notificado.")
        } catch {
            toast = ToastInfo(kind: .error, message: "No se pudo cambiar el rol.")
        }
    }

    private func accionDesactivar() async {
        guard let u = usuario else { return }
        do {
            try await usuarios.actualizarEstado(id: u.id, nuevo: .inactivo)
            toast = ToastInfo(kind: .exito, message: "Cuenta desactivada.")
        } catch {
            toast = ToastInfo(kind: .error, message: "No se pudo desactivar.")
        }
    }

    private func accionReactivar() async {
        guard let u = usuario else { return }
        do {
            try await usuarios.actualizarEstado(id: u.id, nuevo: .activo)
            await notificaciones.notificarCuentaActivada(usuarioId: u.id, rol: u.rol)
            toast = ToastInfo(kind: .exito, message: "Cuenta reactivada.")
        } catch {
            toast = ToastInfo(kind: .error, message: "No se pudo reactivar.")
        }
    }

    // MARK: - Small helpers

    private func iniciales(_ u: Usuario) -> String {
        let a = u.nombres.first.map(String.init) ?? ""
        let b = u.apellidos.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }

    private var divider: some View { Divider() }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 12)
    }

    private func miniStat(titulo: String, valor: Int, icono: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icono)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text("\(valor)")
                .font(.headline)
            Text(titulo)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
        )
    }

    private struct ToastInfo: Identifiable {
        let id = UUID()
        let kind: AppToastKind
        let message: String
    }
}
