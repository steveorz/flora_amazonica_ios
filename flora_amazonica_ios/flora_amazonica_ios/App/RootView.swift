//
//  RootView.swift
//
//  Decide qué mostrar según splash y la sesión guardada.
//

import SwiftUI

struct RootView: View {

    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies
    @State private var splashFinished = false
    @State private var didRestoreSession = false
    @State private var datosPreparados = false

    var body: some View {
        Group {
            if !splashFinished {
                SplashView()
            } else if let u = session.usuario {
                if u.estado == .pendiente {
                    InactiveAccountView(usuario: u, onBack: { session.logout() })
                } else if u.rol == .validador {
                    ValidadorWebView(usuario: u, onBack: { session.logout() })
                } else if !datosPreparados {
                    // Tras el login: mantiene la pantalla de carga mientras se
                    // traen las especies y se precalientan las imágenes, para
                    // que el home aparezca completo y no se vean fotos cargando.
                    SplashView()
                        .task { await prepararDatos() }
                } else {
                    shell(for: u)
                }
            } else {
                AuthFlowView()
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .task {
            await restoreSessionIfNeeded()
        }
        .onChange(of: session.usuario?.id) { _, nuevo in
            if nuevo == nil { datosPreparados = false }
        }
    }

    @ViewBuilder
    private func shell(for usuario: Usuario) -> some View {
        switch usuario.rol {
        case .registrador:   RegistradorShell()
        case .consultor:     ConsultorShell()
        case .administrador: AdminShell()
        case .validador:     ValidadorWebView(usuario: usuario, onBack: { session.logout() })
        }
    }

    /// Carga las especies y precalienta las portadas en la caché de URLSession
    /// (AsyncImage usa la misma sesión compartida, así que luego salen al instante).
    private func prepararDatos() async {
        let start = Date()

        if especies.especies.isEmpty {
            await especies.cargar()
        }
        await prefetchPortadas()

        // Duración mínima para que la transición no parpadee.
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 0.9 - elapsed)
        if remaining > 0 {
            try? await Task.sleep(for: .seconds(remaining))
        }
        withAnimation(.easeInOut(duration: 0.35)) {
            datosPreparados = true
        }
    }

    private func prefetchPortadas() async {
        let urls = especies.especies
            .compactMap { $0.fotos.first?.url }
            .filter { !$0.isFileURL }
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    // Timeout corto: si una foto no llega, no bloquea la entrada.
                    let request = URLRequest(url: url, timeoutInterval: 8)
                    _ = try? await URLSession.shared.data(for: request)
                }
            }
        }
    }

    private func restoreSessionIfNeeded() async {
        guard !didRestoreSession else { return }
        didRestoreSession = true

        let start = Date()
        await session.restoreSession()
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 1.5 - elapsed)
        if remaining > 0 {
            try? await Task.sleep(for: .seconds(remaining))
        }
        splashFinished = true
    }
}

#Preview {
    RootView()
        .environment(SessionStore())
        .environment(EspecieService(repo: MockEspecieRepository()))
        .environment(UsuarioService(repo: MockUsuarioRepository()))
        .environment(NotificacionService(repo: MockNotificacionRepository()))
        .environment(ValorMorfologicoService(repo: MockValorMorfologicoRepository()))
        .environment(FavoritosStore())
        .environment(ConnectivityStore())
        .environment(AppPreferences())
}
