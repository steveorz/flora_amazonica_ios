import SwiftUI

/// Cápsulas de selección múltiple en cristal.
/// El chip activo se tinta en verde de marca.
struct AppChips<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Set<Item>
    let labelFor: (Item) -> String

    var body: some View {
        // Relleno sólido (no vidrio): sobre superficies planas el Liquid Glass
        // proyecta un halo gris desparejo, así que aquí usamos el estilo de chip
        // estándar: gris translúcido para inactivo, verde de marca para activo.
        ChipsFlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                let isOn = selection.contains(item)
                Button {
                    if isOn { selection.remove(item) } else { selection.insert(item) }
                } label: {
                    Text(labelFor(item))
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(isOn ? Color.onBrand : Color.primary)
                        .background(
                            Capsule().fill(isOn ? Color.brand : Color(.secondarySystemFill))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ChipsFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            totalWidth = max(totalWidth, x)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: totalWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            sub.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
