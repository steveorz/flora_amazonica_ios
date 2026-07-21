import SwiftUI
import AVFoundation

// MARK: - Motor compartido de reproducción

/// Motor único de reproducción para todo el flujo de auth: un solo par de
/// AVPlayers que todas las pantallas comparten. Así el fotograma es idéntico
/// en splash, login, registro y recuperación, y la transición entre pantallas
/// se ve perfectamente continua.
@MainActor
final class VideoFondoMotor {
    static let compartido = VideoFondoMotor()

    /// Aviso de cambio de clip; userInfo trae "anterior" y "siguiente" (Int).
    static let clipCambio = Notification.Name("VideoFondoMotor.clipCambio")

    private(set) var players: [AVPlayer] = []
    private(set) var actual = 0

    /// Duración del fundido cruzado entre clips.
    let fundido = 1.0

    private let nombres = ["login_fondo_1", "login_fondo_2"]
    private var preparado = false
    private var observadores: [Any] = []

    private init() {}

    /// Carga los clips una sola vez; llamadas posteriores no hacen nada.
    /// Los players se crean de inmediato (las vistas pueden conectarse ya);
    /// los avisos de fin de clip se instalan cuando se conoce la duración.
    func preparar() {
        guard !preparado else { return }
        preparado = true

        // Si el app pasa a segundo plano, iOS pausa el video; se reanuda al volver.
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                VideoFondoMotor.compartido.reanudar()
            }
        }

        var assets: [(AVPlayer, AVURLAsset)] = []
        for nombre in nombres {
            guard let url = Bundle.main.url(forResource: nombre, withExtension: "mp4") else { continue }
            let asset = AVURLAsset(url: url)

            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            player.isMuted = true
            // Nota: se deja automaticallyWaitsToMinimizeStalling en true (el
            // valor por defecto). Con false, un play() antes de que el item
            // esté listo deja el video congelado en el primer fotograma.
            player.preventsDisplaySleepDuringVideoPlayback = false

            players.append(player)
            assets.append((player, asset))
        }

        players.first?.play()

        Task { @MainActor in
            for (player, asset) in assets {
                guard let duracion = try? await asset.load(.duration) else { continue }

                // Un segundo antes del final del clip comienza el fundido al siguiente.
                let inicioFundido = CMTimeSubtract(duracion, CMTime(seconds: fundido, preferredTimescale: 600))
                let token = player.addBoundaryTimeObserver(
                    forTimes: [NSValue(time: inicioFundido)],
                    queue: .main
                ) {
                    MainActor.assumeIsolated {
                        VideoFondoMotor.compartido.pasarAlSiguienteClip()
                    }
                }
                observadores.append(token)
            }

            // Garantía de arranque: si el play() inicial se emitió antes de
            // que el item estuviera listo, este segundo play() (inofensivo si
            // ya está reproduciendo) lo pone en marcha.
            reanudar()
        }
    }

    private func pasarAlSiguienteClip() {
        guard players.count > 1 else {
            // Con un solo clip disponible, simplemente se repite.
            players.first?.seek(to: .zero)
            return
        }

        let anterior = actual
        let siguiente = (actual + 1) % players.count
        actual = siguiente

        players[siguiente].seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        players[siguiente].play()

        // Todas las vistas conectadas cruzan sus capas a la vez.
        NotificationCenter.default.post(
            name: Self.clipCambio,
            object: nil,
            userInfo: ["anterior": anterior, "siguiente": siguiente]
        )

        // Terminado el fundido, el clip anterior queda pausado y listo desde cero.
        DispatchQueue.main.asyncAfter(deadline: .now() + fundido + 0.1) { [weak self] in
            guard let self, self.actual == siguiente else { return }
            self.players[anterior].pause()
            self.players[anterior].seek(to: .zero)
        }
    }

    private func reanudar() {
        guard players.indices.contains(actual) else { return }
        players[actual].play()
    }
}

// MARK: - Vista de video

/// Vista de video conectada al motor compartido: cada pantalla tiene sus
/// propias AVPlayerLayer, pero todas leen el mismo fotograma del motor.
struct VideoFondoAuth: UIViewRepresentable {
    func makeUIView(context: Context) -> VideoFondoUIView {
        VideoFondoUIView()
    }

    func updateUIView(_ uiView: VideoFondoUIView, context: Context) {}
}

final class VideoFondoUIView: UIView {
    private var capas: [AVPlayerLayer] = []
    private var observador: (any NSObjectProtocol)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let motor = VideoFondoMotor.compartido
        motor.preparar()

        for (i, player) in motor.players.enumerated() {
            let capa = AVPlayerLayer(player: player)
            capa.videoGravity = .resizeAspectFill
            capa.frame = bounds
            capa.opacity = i == motor.actual ? 1 : 0
            layer.addSublayer(capa)
            capas.append(capa)
        }

        observador = NotificationCenter.default.addObserver(
            forName: VideoFondoMotor.clipCambio,
            object: nil,
            queue: .main
        ) { [weak self] nota in
            guard let anterior = nota.userInfo?["anterior"] as? Int,
                  let siguiente = nota.userInfo?["siguiente"] as? Int else { return }
            MainActor.assumeIsolated {
                self?.cruzarCapas(de: anterior, a: siguiente)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) no está soportado")
    }

    deinit {
        if let observador {
            NotificationCenter.default.removeObserver(observador)
        }
    }

    private func cruzarCapas(de anterior: Int, a siguiente: Int) {
        guard capas.indices.contains(anterior), capas.indices.contains(siguiente) else { return }
        CATransaction.begin()
        CATransaction.setAnimationDuration(VideoFondoMotor.compartido.fundido)
        capas[siguiente].opacity = 1
        capas[anterior].opacity = 0
        CATransaction.commit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for capa in capas {
            capa.frame = bounds
        }
        CATransaction.commit()
    }
}

// MARK: - Filtro cinematográfico compartido

/// Filtro que unifica el look del video en todo el flujo de auth:
/// tinte verde selva (más denso arriba y abajo) y viñeta hacia los bordes.
struct FiltroVideoAuth: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.01, green: 0.10, blue: 0.06).opacity(0.55), location: 0),
                    .init(color: Color(red: 0.01, green: 0.10, blue: 0.06).opacity(0.12), location: 0.40),
                    .init(color: Color(red: 0.00, green: 0.07, blue: 0.04).opacity(0.50), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [.clear, .black.opacity(0.42)],
                center: .center,
                startRadius: 160,
                endRadius: 560
            )
        }
    }
}

// MARK: - Fondo desenfocado para pantallas derivadas del login

/// Fondo de las pantallas que derivan del login (registro, recuperación de
/// contraseña, cuenta creada) y del splash: el mismo video de la Amazonía
/// —sincronizado por el motor compartido— totalmente desenfocado, con el
/// mismo filtro cinematográfico del login y un velo extra de legibilidad.
struct FondoAuthDesenfocado: View {
    var body: some View {
        ZStack {
            Color.black

            VideoFondoAuth()

            Rectangle()
                .fill(.ultraThinMaterial)

            FiltroVideoAuth()

            Color.black.opacity(0.12)
        }
        .ignoresSafeArea()
    }
}
