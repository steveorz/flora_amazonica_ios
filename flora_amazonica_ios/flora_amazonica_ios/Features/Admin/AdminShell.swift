import SwiftUI

struct AdminShell: View {

    enum TabID: Hashable {
        case inicio, usuarios, notificaciones
    }

    @State private var selection: TabID = .inicio
    @Environment(NotificacionService.self) private var notificaciones

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: .inicio) {
                NavigationStack { DashboardAdminView(onJumpToUsuarios: { selection = .usuarios }) }
                    .offlineBanner()
                    .tint(.brand)
            }
            Tab("Usuarios", systemImage: "person.2.fill", value: .usuarios) {
                NavigationStack { UsuariosView() }
                    .offlineBanner()
                    .tint(.brand)
            }
            Tab("Avisos", systemImage: "bell.fill", value: .notificaciones) {
                NavigationStack { NotificacionesView() }
                    .offlineBanner()
                    .tint(.brand)
            }
            .badge(notificaciones.noLeidas)
        }
        // Verde amazónico solo para la selección de la barra; el contenido
        // de cada pestaña recupera el tinte neutro de marca arriba.
        .tint(Color.navigationSelection)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
