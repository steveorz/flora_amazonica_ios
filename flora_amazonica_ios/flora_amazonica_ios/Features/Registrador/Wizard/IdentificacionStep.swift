import SwiftUI

/// R-04: identificación. Formulario agrupado nativo (se adapta solo a claro/oscuro).
/// Autocompleta contra el catálogo validado y rellena el autor con el usuario actual.
struct IdentificacionStep: View {

    @Bindable var store: RegistroWizardStore
    @Environment(EspecieService.self) private var especies
    @Environment(SessionStore.self) private var session

    @State private var sugerencias: [Especie] = []
    @State private var sugerenciasFamilia: [String] = []
    @State private var familiaBloqueada: Bool = false
    @State private var searchTask: Task<Void, Never>? = nil

    private let paises = [
        "Perú", "Brasil", "Bolivia", "Ecuador", "Colombia",
        "Venezuela", "Guyana", "Surinam"
    ]

    var body: some View {
        Form {
            Section {
                campo("Nombre científico *", text: $store.draft.nombreCientifico,
                      prompt: "Ej.: Cedrela odorata")
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .onChange(of: store.draft.nombreCientifico) { _, q in
                        actualizarSugerencias(q)
                    }

                ForEach(sugerencias) { e in
                    Button {
                        seleccionar(e)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf")
                                .foregroundStyle(Color.navigationSelection)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.nombreCientifico)
                                    .font(.subheadline.italic())
                                    .foregroundStyle(.primary)
                                Text(e.familia)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                campo("Autor", text: $store.draft.autorNombre,
                      prompt: "Tu nombre")

                HStack {
                    campo(familiaBloqueada ? "Familia (auto)" : "Familia *",
                          text: $store.draft.familia,
                          prompt: "Ej.: Meliaceae")
                        .disabled(familiaBloqueada)
                        .onChange(of: store.draft.familia) { _, q in
                            if !familiaBloqueada {
                                actualizarSugerenciasFamilia(q)
                            }
                        }
                    if familiaBloqueada {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                ForEach(sugerenciasFamilia, id: \.self) { f in
                    Button {
                        store.draft.familia = f
                        sugerenciasFamilia = []
                    } label: {
                        HStack {
                            Text(f)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            } header: {
                Text("Taxonomía")
            } footer: {
                Text("Si el nombre científico está en el catálogo, la familia se autocompleta y queda bloqueada.")
            }

            Section("Detalle") {
                campo("Nombre local *", text: $store.draft.nombreLocal,
                      prompt: "Ej.: Cedro")

                VStack(alignment: .leading, spacing: 4) {
                    Text("Descripción")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Notas generales de la especie…",
                              text: $store.draft.descripcion, axis: .vertical)
                        .lineLimit(3...6)
                }
                .padding(.vertical, 2)
            }

            Section {
                AppChips(
                    items: paises,
                    selection: Binding(
                        get: { Set(store.draft.distribucionPaises) },
                        set: { store.draft.distribucionPaises = Array($0) }
                    ),
                    labelFor: { $0 }
                )
                .listRowInsets(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))
                .listRowBackground(Color.clear)
            } header: {
                Text("Distribución por países *")
            } footer: {
                Text("Marca todos los países donde se ha reportado la especie.")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            familiaBloqueada = especies.especies.contains { $0.nombreCientifico == store.draft.nombreCientifico }
            // Autor por defecto: el usuario con el que se creó la cuenta.
            if store.draft.autorNombre.isEmpty {
                store.draft.autorNombre = session.usuario?.nombreCompleto ?? ""
            }
        }
    }

    /// Fila de formulario: etiqueta pequeña arriba, campo debajo (estilo Salud/Contactos).
    private func campo(_ titulo: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(prompt, text: text)
        }
        .padding(.vertical, 2)
    }

    private func actualizarSugerencias(_ q: String) {
        if familiaBloqueada {
            familiaBloqueada = false
        }
        guard q.count >= 2 else { sugerencias = []; return }

        let lower = q.lowercased()
        sugerencias = Array(
            especies.especies
                .filter { $0.estado == .validado && $0.nombreCientifico.lowercased().contains(lower) }
                .prefix(5)
        )

        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            if Task.isCancelled { return }
            await especies.cargar()
            if !Task.isCancelled {
                sugerencias = Array(
                    especies.especies
                        .filter { $0.estado == .validado && $0.nombreCientifico.lowercased().contains(lower) }
                        .prefix(5)
                )
            }
        }
    }

    private func actualizarSugerenciasFamilia(_ q: String) {
        guard q.count >= 2 else { sugerenciasFamilia = []; return }
        let lower = q.lowercased()

        let familiasActivas = Set(especies.especies.filter { $0.estado == .validado }.map { $0.familia })

        sugerenciasFamilia = Array(
            familiasActivas
                .filter { $0.lowercased().contains(lower) }
                .sorted()
                .prefix(5)
        )

        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled { return }
            await especies.cargar()
            if !Task.isCancelled {
                let familiasActivas = Set(especies.especies.filter { $0.estado == .validado }.map { $0.familia })
                sugerenciasFamilia = Array(
                    familiasActivas
                        .filter { $0.lowercased().contains(lower) }
                        .sorted()
                        .prefix(5)
                )
            }
        }
    }

    private func seleccionar(_ e: Especie) {
        store.draft.catalogId = e.id
        store.draft.nombreCientifico = e.nombreCientifico
        store.draft.autorNombre = e.autorNombre
        store.draft.familia = e.familia
        familiaBloqueada = true
        sugerencias = []
    }
}
