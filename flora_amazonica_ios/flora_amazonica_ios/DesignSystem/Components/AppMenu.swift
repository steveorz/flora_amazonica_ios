import SwiftUI

struct AppMenu<Item: Hashable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Item?
    let labelFor: (Item) -> String
    var placeholder: String = "Selecciona…"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Menu {
                ForEach(items, id: \.self) { item in
                    Button(labelFor(item)) { selection = item }
                }
            } label: {
                HStack {
                    Text(selection.map(labelFor) ?? placeholder)
                        .foregroundStyle(selection == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }
}
