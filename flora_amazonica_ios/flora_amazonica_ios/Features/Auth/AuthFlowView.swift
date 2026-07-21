import SwiftUI

/// Coordinador del flujo de auth: Login → Register/Recover → success → Login.
struct AuthFlowView: View {

    enum Route: Hashable {
        case register(email: String = "")
        case accountCreated
        case recover
        case newPassword(email: String)
    }

    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(
                onRegister: { email in path.append(.register(email: email)) },
                onRecover:  { path.append(.recover) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .register(let email):
                    RegisterView(
                        initialEmail: email,
                        onCreated: { path.append(.accountCreated) }
                    )

                case .accountCreated:
                    AccountCreatedView(onBackToLogin: { path.removeAll() })

                case .recover:
                    RecoverPasswordView(onContinue: { email in
                        path.append(.newPassword(email: email))
                    })

                case .newPassword(let email):
                    NewPasswordView(email: email, onDone: { path.removeAll() })
                }
            }
        }
    }
}
