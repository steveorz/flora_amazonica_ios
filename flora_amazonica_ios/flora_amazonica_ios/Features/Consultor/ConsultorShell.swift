import SwiftUI

struct ConsultorShell: View {

    enum TabID: Hashable {
        case inicio, favoritos, avisos, buscar
    }

    @State private var selection: TabID = .inicio
    @Environment(NotificacionService.self) private var notificaciones

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: .inicio) {
                NavigationStack { HomeConsultorView() }
                    .offlineBanner()
                    .tint(.brand)
            }

            Tab("Favoritos", systemImage: "heart.fill", value: .favoritos) {
                NavigationStack { FavoritosView() }
                    .offlineBanner()
                    .tint(.brand)
            }

            Tab("Avisos", systemImage: "bell.fill", value: .avisos) {
                NavigationStack { NotificacionesView() }
                    .offlineBanner()
                    .tint(.brand)
            }
            .badge(notificaciones.noLeidas)

            Tab("Buscar", systemImage: "magnifyingglass", value: .buscar, role: .search) {
                   NavigationStack { BuscarLandingView() }
                    .offlineBanner()
                    .tint(.brand)
            }
        }
        // Verde amazónico solo para la selección de la barra; el contenido
        // de cada pestaña recupera el tinte neutro de marca arriba.
        .tint(Color.navigationSelection)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ConsultorShell()
        .environment(SessionStore())
        .environment(EspecieService(repo: MockEspecieRepository()))
        .environment(UsuarioService(repo: MockUsuarioRepository()))
        .environment(NotificacionService(repo: MockNotificacionRepository()))
        .environment(FavoritosStore())
        .environment(ConnectivityStore())
        .environment(AppPreferences())
}
