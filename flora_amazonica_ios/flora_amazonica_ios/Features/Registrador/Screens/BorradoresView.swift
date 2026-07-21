import SwiftUI

/// R-15: lista de borradores. Tocar uno retoma el wizard donde quedó.
struct BorradoresView: View {

    @State private var drafts: [EspecieDraft] = []
    @State private var presentingDraft: EspecieDraft?

    var body: some View {
        Group {
            if drafts.isEmpty {
                EmptyState(
                    systemImage: "doc.text",
                    title: "Sin borradores",
                    message: "Empieza un nuevo registro y se guardará aquí automáticamente."
                )
            } else {
                List {
                    ForEach(drafts) { d in
                        Button {
                            presentingDraft = d
                        } label: {
                            row(d)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                DraftStorage.delete(id: d.id)
                                drafts = DraftStorage.loadAll()
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Borradores")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .onAppear { drafts = DraftStorage.loadAll() }
        .fullScreenCover(item: $presentingDraft, onDismiss: {
            drafts = DraftStorage.loadAll()
        }) { d in
            NuevoRegistroView(draft: d)
        }
    }

    private func row(_ d: EspecieDraft) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brand.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color.brand)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(d.nombreCientifico.isEmpty ? "Borrador sin título" : d.nombreCientifico)
                    .font(.body.italic())
                    .lineLimit(1)
                Text("Paso \(d.pasoActual) de 7")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(d.fechaActualizacion, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}
