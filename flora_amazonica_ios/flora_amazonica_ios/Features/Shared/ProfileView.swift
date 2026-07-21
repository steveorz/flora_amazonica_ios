import SwiftUI

/// C-09: datos del usuario, avatar, acciones de cuenta.
/// Diseño de listas agrupadas al estilo de la hoja de Cuenta de Apple.
struct ProfileView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        List {
            if let u = session.usuario {
                Section {
                    HStack(spacing: 14) {
                        ProfileAvatarView(user: u, size: 64)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(u.nombreCompleto)
                                .font(.headline)
                            Text(u.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Información") {
                    LabeledContent("Rol",         value: u.rol.label)
                    LabeledContent("DNI",         value: u.dni)
                    LabeledContent("Institución", value: u.institucion)
                    LabeledContent("Cargo",       value: u.cargo)
                }

                Section {
                    NavigationLink {
                        ConfiguracionView()
                    } label: {
                        Label("Configuración", systemImage: "gearshape")
                    }
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        Label("Cambiar contraseña", systemImage: "lock.rotation")
                    }
                }

                Section {
                    Button("Cerrar sesión", role: .destructive) {
                        session.logout()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }
}
