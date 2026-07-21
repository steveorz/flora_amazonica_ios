import SwiftUI

@main
struct FloraAmazonicaApp: App {

    // NOTE: login sigue usando el backend real (SessionStore -> RealAuthRepository).
    // Los repositorios ahora usan la conexión Real al backend en producción
    @State private var session        = SessionStore()
    @State private var especies       = EspecieService(repo: RealEspecieRepository())
    @State private var usuarios       = UsuarioService(repo: RealUsuarioRepository())
    @State private var notificaciones = NotificacionService(repo: RealNotificacionRepository())
    @State private var valores        = ValorMorfologicoService(repo: RealValorMorfologicoRepository())
    @State private var favoritos      = FavoritosStore()
    @State private var conectividad   = ConnectivityStore()
    @State private var preferencias   = AppPreferences()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(especies)
                .environment(usuarios)
                .environment(notificaciones)
                .environment(valores)
                .environment(favoritos)
                .environment(conectividad)
                .environment(preferencias)
                .preferredColorScheme(preferencias.colorScheme)
        }
    }
}
