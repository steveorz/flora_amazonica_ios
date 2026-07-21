import SwiftUI

struct AppCheckboxGroup<Item: Hashable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Set<Item>
    let labelFor: (Item) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(items, id: \.self) { item in
                let isOn = selection.contains(item)
                Button {
                    if isOn { selection.remove(item) } else { selection.insert(item) }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isOn ? "checkmark.square.fill" : "square")
                            .foregroundStyle(isOn ? Color.brand : .secondary)
                            .font(.system(size: 20))
                        Text(labelFor(item))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
