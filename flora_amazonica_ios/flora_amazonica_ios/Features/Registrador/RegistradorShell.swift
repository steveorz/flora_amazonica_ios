import SwiftUI

struct RegistradorShell: View {

    enum TabID: Hashable {
        case inicio, misRegistros, nuevo, borradores, avisos
    }

    @State private var selection: TabID = .inicio
    @State private var lastNonNuevo: TabID = .inicio
    @State private var nuevoPresented: Bool = false
    @Environment(NotificacionService.self) private var notificaciones

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: .inicio) {
                NavigationStack { HomeRegistradorView() }
                    .offlineBanner()
                    .tint(.brand)
            }

            Tab("Mis registros", systemImage: "list.bullet.rectangle", value: .misRegistros) {
                NavigationStack { MisRegistrosView() }
                    .offlineBanner()
                    .tint(.brand)
            }

            // Pestaña protagonista. Al tocarla se presenta el wizard fullScreen
            // y la selección vuelve a la pestaña previa.
            Tab(value: .nuevo) {
                Color.clear
            } label: {
                Label {
                    Text("Nuevo")
                } icon: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Tab("Borradores", systemImage: "doc.text", value: .borradores) {
                NavigationStack { BorradoresView() }
                    .offlineBanner()
                    .tint(.brand)
            }

            Tab("Avisos", systemImage: "bell.fill", value: .avisos) {
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
        .onChange(of: selection) { _, new in
            if new == .nuevo {
                selection = lastNonNuevo
                nuevoPresented = true
            } else {
                lastNonNuevo = new
            }
        }
        .fullScreenCover(isPresented: $nuevoPresented) {
            NuevoRegistroView()
        }
    }
}
