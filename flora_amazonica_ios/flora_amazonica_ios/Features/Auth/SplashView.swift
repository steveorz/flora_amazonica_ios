import SwiftUI

/// C-01: pantalla de carga.
struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // El mismo video del login (sincronizado por el motor compartido),
            // totalmente desenfocado: al pasar al login la transición es continua.
            FondoAuthDesenfocado()

            VStack(spacing: 18) {
                Image("logo_floramaz")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
                    .padding(26)
                    .glassEffect(.regular.tint(.white.opacity(0.18)), in: Circle())
                    .scaleEffect(pulse ? 1.05 : 1.0)

                Text("FlorAmaz")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                ProgressView()
                    .tint(.white)
                    .padding(.top, 4)
            }
        }
        // Sobre el video desenfocado todo se renderiza en oscuro para que
        // el vidrio y los textos sean legibles.
        .environment(\.colorScheme, .dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
