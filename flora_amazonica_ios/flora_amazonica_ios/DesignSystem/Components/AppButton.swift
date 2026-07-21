import SwiftUI

enum AppButtonVariant {
    case primario       // .glassProminent + brand
    case atencion       // .glassProminent + naranja (acción protagonista)
    case secundario     // .glass
    case terciario      // texto plano
    case destructivo    // rojo
    case icono          // circular .glass
}

struct AppButton: View {
    let title: String
    let systemImage: String?
    let variant: AppButtonVariant
    let action: () -> Void

    init(
        _ title: String = "",
        systemImage: String? = nil,
        variant: AppButtonVariant = .primario,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.action = action
    }

    var body: some View {
        switch variant {
        case .primario:
            // onBrand explícito: glassProminent no invierte el label cuando
            // el tinte brand pasa a blanco en modo oscuro.
            Button(action: action) { labelView.foregroundStyle(Color.onBrand) }
                .buttonStyle(.glassProminent)
                .tint(.brand)

        case .atencion:
            Button(action: action) { labelView }
                .buttonStyle(.glassProminent)
                .tint(.orange)

        case .secundario:
            Button(action: action) { labelView }
                .buttonStyle(.glass)

        case .terciario:
            Button(action: action) { labelView }
                .buttonStyle(.plain)
                .foregroundStyle(Color.brand)

        case .destructivo:
            Button(role: .destructive, action: action) { labelView }
                .buttonStyle(.glassProminent)
                .tint(.red)

        case .icono:
            Button(action: action) {
                Image(systemName: systemImage ?? "circle")
                    .padding(8)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }

    @ViewBuilder
    private var labelView: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage) }
            if !title.isEmpty { Text(title) }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
    }
}
