import SwiftUI
import AVFoundation

/// C-03: inicio de sesión.
/// Diseño minimalista: palabra animada tipo máquina de escribir al centro y acciones al pie.
/// Flujo inteligente: al continuar con el correo se verifica si existe la cuenta;
/// si no existe se navega al registro y si existe se revela el campo de contraseña.
struct LoginView: View {
    var onRegister: (String) -> Void
    var onRecover: () -> Void

    @Environment(SessionStore.self) private var session

    private enum Campo: Hashable {
        case email, password
    }

    @State private var email = ""
    @State private var password = ""
    @State private var mostrarPassword = false      // paso 2 visible
    @State private var passwordVisible = false      // ojo del campo contraseña
    @State private var loading = false
    @State private var errorMensaje: String?
    @State private var aparecio = false
    @FocusState private var foco: Campo?

    private let formMaxWidth: CGFloat = 380
    private let controlHeight: CGFloat = 56

    private var ocupado: Bool { loading }

    private var emailLimpio: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var puedeEnviar: Bool {
        mostrarPassword ? (!emailLimpio.isEmpty && !password.isEmpty) : !emailLimpio.isEmpty
    }

    var body: some View {
        ZStack {
            fondo

            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 32)

                        saludo
                            .aparicion(aparecio, indice: 0)

                        Spacer(minLength: 28)

                        formulario
                            .aparicion(aparecio, indice: 1)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: formMaxWidth)
                    .frame(maxWidth: .infinity, minHeight: geo.size.height)
                    .padding(.horizontal, 24)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarBackButtonHidden(true)
        // Sobre el video de fondo la pantalla siempre se renderiza en oscuro,
        // para que el texto y los materiales de vidrio sean legibles.
        .environment(\.colorScheme, .dark)
        .onAppear { aparecio = true }
        .onChange(of: email) {
            // Si el usuario corrige el correo, se vuelve al paso 1.
            guard mostrarPassword else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                mostrarPassword = false
                password = ""
                errorMensaje = nil
            }
        }
    }

    // MARK: - Fondo

    /// Fondo de video: los dos clips de la Amazonía se alternan en bucle con
    /// fundido cruzado. Abajo, un desenfoque progresivo (el material se
    /// intensifica hacia el pie) deja el video nítido donde está la palabra
    /// animada y da legibilidad a los controles de vidrio. Encima, un filtro
    /// cinematográfico en tres capas translúcidas: tinte verde selva, viñeta
    /// y un halo oscuro tras el titular para que la tipografía blanca resalte.
    private var fondo: some View {
        ZStack {
            Color.black

            VideoFondoAuth()

            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.30),
                            .init(color: .black.opacity(0.85), location: 0.55),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            FiltroVideoAuth()
            haloTitular
        }
        .ignoresSafeArea()
    }

    /// Halo oscuro y difuso detrás del titular animado y de «la flora
    /// amazónica»: garantiza contraste al texto blanco sin tapar el video.
    private var haloTitular: some View {
        RadialGradient(
            colors: [.black.opacity(0.45), .clear],
            center: UnitPoint(x: 0.5, y: 0.30),
            startRadius: 20,
            endRadius: 300
        )
    }

    // MARK: - Saludo

    private var saludo: some View {
        VStack(spacing: 8) {
            PalabraTecleada()

            Text("la flora amazónica")
                .font(.system(size: 26, weight: .medium, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
        }
    }

    // MARK: - Formulario

    private var formulario: some View {
        VStack(spacing: 12) {
            campoEmail

            if mostrarPassword {
                campoPassword
                    .transition(.opacity.combined(with: .move(edge: .top)))

                Button("¿Olvidaste tu contraseña?", action: onRecover)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
                    .transition(.opacity)
            }

            if let errorMensaje {
                bannerError(errorMensaje)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            botonPrincipal
                .padding(.top, 4)
        }
    }

    private var campoEmail: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 15))
                .foregroundStyle(foco == .email ? .white : .secondary)

            TextField("Correo electrónico", text: $email)
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .focused($foco, equals: .email)
                .submitLabel(mostrarPassword ? .next : .continue)
                .onSubmit(enviar)

            if !email.isEmpty && foco == .email {
                Button {
                    email = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(.systemGray3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: controlHeight)
        .glassEffect(.regular, in: Capsule(style: .continuous))
        .overlay(bordeCampo(activo: foco == .email))
        .animation(.easeOut(duration: 0.18), value: foco)
    }

    private var campoPassword: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 15))
                .foregroundStyle(foco == .password ? .white : .secondary)

            ZStack {
                SecureField("Contraseña", text: $password)
                    .opacity(passwordVisible ? 0 : 1)
                TextField("Contraseña", text: $password)
                    .opacity(passwordVisible ? 1 : 0)
            }
            .font(.system(size: 17))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.password)
            .focused($foco, equals: .password)
            .submitLabel(.go)
            .onSubmit(enviar)

            Button {
                passwordVisible.toggle()
            } label: {
                Image(systemName: passwordVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: controlHeight)
        .glassEffect(.regular, in: Capsule(style: .continuous))
        .overlay(bordeCampo(activo: foco == .password))
        .animation(.easeOut(duration: 0.18), value: foco)
    }

    /// Borde que resalta el campo activo sobre el vidrio.
    private func bordeCampo(activo: Bool) -> some View {
        Capsule(style: .continuous)
            .stroke(.white.opacity(activo ? 0.75 : 0), lineWidth: 1.5)
    }

    private func bannerError(_ mensaje: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14))
            Text(mensaje)
                .font(.footnote)
        }
        .foregroundStyle(.white)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(.red.opacity(0.45)), in: .rect(cornerRadius: 16))
    }

    private var botonPrincipal: some View {
        Button(action: enviar) {
            HStack(spacing: 10) {
                if loading {
                    ProgressView()
                        .tint(.white)
                }
                Text(textoBotonPrincipal)
                    .font(.system(size: 17, weight: .semibold))
                if !loading && !mostrarPassword {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: controlHeight)
            .opacity(puedeEnviar && !ocupado ? 1 : 0.5)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        // Negro fijo: el login siempre va en modo oscuro con texto blanco.
        .tint(.black)
        .disabled(!puedeEnviar || ocupado)
    }

    private var textoBotonPrincipal: String {
        if mostrarPassword {
            return loading ? "Iniciando sesión…" : "Iniciar sesión"
        }
        return loading ? "Verificando…" : "Continuar"
    }

    // MARK: - Social

    // MARK: - Acciones

    private func enviar() {
        guard !ocupado else { return }

        guard esEmailValido(emailLimpio) else {
            mostrarError("Ingresa un correo válido.")
            foco = .email
            return
        }

        // Paso 1: verificar si el correo ya tiene cuenta.
        // Si existe se revela la contraseña; si no, se lleva al registro.
        if !mostrarPassword {
            limpiarError()
            loading = true
            Task {
                let resultado = await session.emailExists(emailLimpio)
                loading = false
                switch resultado {
                case .success(true):
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        mostrarPassword = true
                    }
                    try? await Task.sleep(for: .milliseconds(380))
                    foco = .password

                case .success(false):
                    foco = nil
                    onRegister(emailLimpio)

                case .failure(let err):
                    mostrarError(err.errorDescription)
                }
            }
            return
        }

        // Paso 2: iniciar sesión.
        guard !password.isEmpty else {
            mostrarError("Ingresa tu contraseña.")
            foco = .password
            return
        }

        limpiarError()
        loading = true
        foco = nil
        Task {
            let err = await session.login(email: emailLimpio, password: password)
            loading = false
            if let err {
                mostrarError(err.errorDescription)
            } else {
                hapticoExito()
            }
        }
    }


    // MARK: - Utilidades

    private func mostrarError(_ mensaje: String?) {
        guard let mensaje else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            errorMensaje = mensaje
        }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func limpiarError() {
        withAnimation(.easeOut(duration: 0.2)) {
            errorMensaje = nil
        }
    }

    private func hapticoExito() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func esEmailValido(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

// MARK: - Palabra animada tipo máquina de escribir

/// Palabra grande que se escribe y se borra letra por letra, con cursor
/// parpadeante, rotando acciones que se pueden hacer dentro del app.
private struct PalabraTecleada: View {
    /// Acciones del app: catálogo, búsqueda, registro con fotos y ubicación,
    /// favoritos y consulta de fichas técnicas.
    private static let palabras = [
        "DESCUBRE", "EXPLORA", "REGISTRA", "IDENTIFICA", "FOTOGRAFÍA",
        "DOCUMENTA", "CONSULTA", "CLASIFICA", "CONSERVA", "APRENDE"
    ]

    @State private var texto = ""
    @State private var cursorVisible = true

    var body: some View {
        HStack(spacing: 5) {
            Text(texto)
                .font(.system(size: 44, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 8, y: 2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            RoundedRectangle(cornerRadius: 1.5)
                .fill(.white)
                .frame(width: 3.5, height: 40)
                .opacity(cursorVisible ? 1 : 0)
        }
        .frame(height: 60)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                cursorVisible = false
            }
        }
        .task { await animarPalabras() }
    }

    /// Ciclo infinito: escribe la palabra, pausa, la borra y pasa a la siguiente.
    /// Se cancela cuando la vista desaparece gracias a `.task`; al volver a
    /// aparecer, el ciclo arranca de nuevo desde texto vacío.
    ///
    /// Cada paso asigna el prefijo exacto de la palabra (en vez de añadir o
    /// quitar letras sobre lo que hubiera), así un ciclo cancelado a mitad de
    /// palabra nunca deja restos que se mezclen con la palabra siguiente.
    private func animarPalabras() async {
        var indice = 0
        texto = ""
        while !Task.isCancelled {
            let palabra = Self.palabras[indice]

            for i in 1...palabra.count {
                texto = String(palabra.prefix(i))
                try? await Task.sleep(for: .milliseconds(120))
                if Task.isCancelled { return }
            }

            try? await Task.sleep(for: .seconds(1.9))
            if Task.isCancelled { return }

            for i in stride(from: palabra.count - 1, through: 0, by: -1) {
                texto = String(palabra.prefix(i))
                try? await Task.sleep(for: .milliseconds(60))
                if Task.isCancelled { return }
            }

            try? await Task.sleep(for: .milliseconds(350))
            indice = (indice + 1) % Self.palabras.count
        }
    }
}

// MARK: - Estilos y modificadores

/// Entrada escalonada: cada bloque aparece con un pequeño retraso.
private struct AparicionEscalonada: ViewModifier {
    let visible: Bool
    let indice: Double

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 18)
            .animation(
                .spring(response: 0.55, dampingFraction: 0.85).delay(indice * 0.07),
                value: visible
            )
    }
}

private extension View {
    func aparicion(_ visible: Bool, indice: Double) -> some View {
        modifier(AparicionEscalonada(visible: visible, indice: indice))
    }
}

#Preview {
    LoginView(onRegister: { _ in }, onRecover: {})
        .environment(SessionStore(repo: MockAuthRepository()))
}
