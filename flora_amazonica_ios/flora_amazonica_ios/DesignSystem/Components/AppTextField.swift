import SwiftUI

enum AppTextFieldKind {
    case text
    case numericWithUnit(String)
    case password
    case multiline
}

struct AppTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var kind: AppTextFieldKind = .text

    @State private var isSecure: Bool = true
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            field
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    // tertiary contrasta con las tarjetas secondarySystemBackground
                    // (p. ej. los acordeones de morfología en modo oscuro).
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(focused ? Color.brand : Color(.separator), lineWidth: focused ? 1.5 : 1)
                )
        }
    }

    @ViewBuilder
    private var field: some View {
        switch kind {
        case .text:
            TextField(placeholder, text: $text)
                .focused($focused)

        case .numericWithUnit(let unit):
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                Text(unit)
                    .foregroundStyle(.secondary)
            }

        case .password:
            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .focused($focused)
                Button { isSecure.toggle() } label: {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

        case .multiline:
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(3...8)
                .focused($focused)
        }
    }
}
