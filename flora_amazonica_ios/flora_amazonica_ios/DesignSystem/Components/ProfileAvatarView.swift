import SwiftUI

struct ProfileAvatarView: View {
    let user: Usuario
    var size: CGFloat = 36

    var initials: String {
        // First initial of first name
        let firstInitial = user.nombres.split(separator: " ").first?.first.map(String.init) ?? ""
        // First initial of last name / surname
        let lastInitial = user.apellidos.split(separator: " ").first?.first.map(String.init) ?? ""
        return (firstInitial + lastInitial).uppercased()
    }

    var body: some View {
        Group {
            if let url = user.avatarUrl {
                // Foto de perfil del backend; monograma mientras carga.
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    /// Monograma gris: el color por defecto del sistema para contactos sin foto.
    private var monogram: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color(.systemGray3), Color(.systemGray)],
                startPoint: .top, endPoint: .bottom
            ))
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundStyle(.white)
            )
    }
}

struct ProfileToolbarItem: View {
    @Environment(SessionStore.self) private var session
    @State private var showProfile = false

    var body: some View {
        if let user = session.usuario {
            Button {
                showProfile = true
            } label: {
                ProfileAvatarView(user: user)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showProfile) {
                ProfileSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }
}

private struct ProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ProfileView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, height: 30)
                                .background(Color(.tertiarySystemFill), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Cerrar")
                    }
                }
        }
    }
}
