import SwiftUI

/// Envoltura de NavigationStack con barra superior de cristal.
/// El avatar se pasa por separado para poder ocultar su fondo de glass.
struct AppScaffold<Content: View, Actions: View, Avatar: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var avatar: () -> Avatar

    var body: some View {
        NavigationStack {
            content()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        actions()
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        avatar()
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
        }
    }
}

extension AppScaffold where Actions == EmptyView {
    init(
        title: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder avatar: @escaping () -> Avatar
    ) {
        self.title = title
        self.content = content
        self.actions = { EmptyView() }
        self.avatar = avatar
    }
}

extension AppScaffold where Avatar == EmptyView {
    init(
        title: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.title = title
        self.content = content
        self.actions = actions
        self.avatar = { EmptyView() }
    }
}

extension AppScaffold where Actions == EmptyView, Avatar == EmptyView {
    init(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
        self.actions = { EmptyView() }
        self.avatar = { EmptyView() }
    }
}
