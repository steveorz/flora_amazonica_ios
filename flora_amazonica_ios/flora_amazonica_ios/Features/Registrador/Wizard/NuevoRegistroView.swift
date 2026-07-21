import SwiftUI

/// Contenedor full-screen del wizard de 7 pasos.
struct NuevoRegistroView: View {

    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies
    @Environment(NotificacionService.self) private var notificaciones
    @Environment(\.dismiss) private var dismiss

    @State private var store: RegistroWizardStore
    @State private var confirmandoCerrar = false

    init() {
        _store = State(initialValue: RegistroWizardStore())
    }

    init(draft: EspecieDraft) {
        _store = State(initialValue: RegistroWizardStore(draft: draft))
    }

    init(especieToEdit: Especie) {
        _store = State(initialValue: RegistroWizardStore(especie: especieToEdit))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.pasoActual <= 6 {
                    ProgressStepper(current: store.pasoActual, total: store.totalPasos)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                }

                pasoActual
                    .frame(maxHeight: .infinity)

                if store.pasoActual < 7 {
                    barraNavegacion
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.bar)
                }
            }
            .navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        confirmandoCerrar = true
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                if store.pasoActual <= 6 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Guardar borrador") {
                            store.guardarBorradorLocal()
                            dismiss()
                        }
                        .font(.subheadline)
                    }
                }
            }
            .confirmationDialog(
                "¿Salir del wizard?",
                isPresented: $confirmandoCerrar,
                titleVisibility: .visible
            ) {
                Button("Guardar borrador y salir") {
                    store.guardarBorradorLocal()
                    dismiss()
                }
                Button("Descartar borrador", role: .destructive) {
                    store.descartarBorrador()
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
        .interactiveDismissDisabled()
        .task {
            // Forzar recarga silenciosa al abrir el wizard
            // para que refleje los cambios recientes hechos por el validador
            await especies.cargar()
        }
    }

    private var titulo: String {
        store.editandoId != nil ? "Editar registro" : "Nuevo registro"
    }

    @ViewBuilder
    private var pasoActual: some View {
        switch store.pasoActual {
        case 1: IdentificacionStep(store: store)
        case 2: HabitoStep(store: store)
        case 3: MorfologiaStep(store: store)
        case 4: UbicacionStep(store: store)
        case 5: FotosStep(store: store)
        case 6: ResumenStep(store: store, onEditar: { paso in store.irA(paso) })
        case 7: ConfirmacionStep(store: store, onCerrar: { dismiss() })
        default: EmptyView()
        }
    }

    @ViewBuilder
    private var barraNavegacion: some View {
        HStack(spacing: 10) {
            if store.pasoActual > 1 {
                AppButton("Anterior", variant: .secundario) {
                    store.retroceder()
                }
                .frame(maxWidth: .infinity)
            }

            if store.pasoActual < 6 {
                AppButton("Siguiente", variant: .primario) {
                    store.avanzar()
                }
                .frame(maxWidth: .infinity)
                .disabled(!store.pasoCompleto(store.pasoActual))
            } else if store.pasoActual == 6 {
                AppButton(store.enviando ? "Enviando…" : "Enviar registro", variant: .atencion) {
                    Task {
                        let registradorId = session.usuario?.id ?? "u-001"
                        await store.enviar(
                            registradorId: registradorId,
                            service: especies
                        )
                        if let res = store.resultado {
                            await notificaciones.notificarCambioEstadoRegistro(
                                usuarioId: registradorId,
                                registroId: res.id,
                                nombreCientifico: res.nombreCientifico,
                                nuevoEstado: .enRevision
                            )
                            store.irA(7)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(store.enviando)
            }
        }
    }
}
