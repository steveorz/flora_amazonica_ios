import SwiftUI

struct PlaceholderScreen: View {
    let title: String

    var body: some View {
        VStack {
            Text("Próximamente")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}
