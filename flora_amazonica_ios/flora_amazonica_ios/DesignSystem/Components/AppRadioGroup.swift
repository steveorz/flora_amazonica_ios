import SwiftUI

struct AppRadioGroup<Item: Hashable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Item?
    let labelFor: (Item) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(items, id: \.self) { item in
                Button {
                    selection = item
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: selection == item ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selection == item ? Color.brand : .secondary)
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
