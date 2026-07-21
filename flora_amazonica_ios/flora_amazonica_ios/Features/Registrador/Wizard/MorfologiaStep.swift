import SwiftUI

/// R-06 a R-10: morfología por hábito con acordeones colapsables, ahora dinámico según el backend.
struct MorfologiaStep: View {

    @Bindable var store: RegistroWizardStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                if store.cargandoCampos {
                    ProgressView("Cargando formulario...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let error = store.errorCampos {
                    Text(error)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Section {
                        if store.draft.habito == .arbol || store.draft.habito == .palmera {
                            DasometricosDynamicWrapper(store: store)
                        } else {
                            Text("Los datos dasométricos no aplican para el hábito seleccionado.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Dasometría")
                            .font(.headline)
                    }

                    if store.camposDinamicos.isEmpty {
                        Text("No se encontraron campos dinámicos para este hábito.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                    } else {
                        FormularioDinamicoView(store: store)
                    }
                }
            }
            .padding(20)
        }
        .refreshable {
            if let habito = store.draft.habito?.label {
                await store.cargarCamposDinamicos(habito: habito)
            }
        }
        .task {
            // Cargar los campos dinámicos si no están cargados o si el hábito cambió
            if let habito = store.draft.habito?.label {
                if store.camposDinamicos.isEmpty || store.habitoCargado != habito {
                    await store.cargarCamposDinamicos(habito: habito)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Morfología")
                .font(.title2.weight(.bold))
            if let h = store.draft.habito {
                Text("Características de \(h.label.lowercased()).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Wrapper Dasométricos (Solo Árbol)

struct DasometricosDynamicWrapper: View {
    @Bindable var store: RegistroWizardStore
    @State private var expanded: Set<String> = ["dasometricos"]
    
    var body: some View {
        acordeon(key: "dasometricos", titulo: "Datos dasométricos", expanded: $expanded) {
            DasometricosForm(store: store)
        }
    }
}

// MARK: - Formulario Dinámico

struct FormularioDinamicoView: View {
    @Bindable var store: RegistroWizardStore
    @State private var expanded: Set<String> = []
    
    var body: some View {
        // Agrupar camposDinamicos por sección manteniendo el orden
        let secciones = Dictionary(grouping: store.camposDinamicos, by: { $0.seccion })
        // Ordenar secciones alfabéticamente o según el primer elemento
        let nombresSecciones = secciones.keys.sorted()
        
        VStack(spacing: 12) {
            ForEach(nombresSecciones, id: \.self) { seccion in
                acordeon(key: seccion, titulo: seccion.capitalized, expanded: $expanded) {
                    VStack(spacing: 16) {
                        ForEach(secciones[seccion] ?? []) { campo in
                            CampoDinamicoView(store: store, campo: campo)
                        }
                    }
                }
            }
        }
        .onAppear {
            if expanded.isEmpty, let first = nombresSecciones.first {
                expanded = [first]
            }
        }
    }
}

struct CampoDinamicoView: View {
    @Bindable var store: RegistroWizardStore
    let campo: CampoMorfologico
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(campo.nombre)
                    .font(.subheadline.weight(.medium))
                if campo.requerido {
                    Text("*").foregroundStyle(.red)
                }
            }
                
            if campo.tipoCampo == "option" || !campo.opciones.isEmpty {
                if campo.tipoSeleccion == "multiple" {
                    // Múltiples toggles o chips (simplified as toggles)
                    ForEach(campo.opciones) { opcion in
                        Toggle(isOn: bindingMulti(opcion.valor)) {
                            Text(opcion.valor)
                                .font(.subheadline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .brand))
                    }
                } else {
                    // Picker
                    Picker(campo.nombre, selection: bindingSingle()) {
                        Text("Seleccionar...").tag("")
                        ForEach(campo.opciones) { opcion in
                            Text(opcion.valor).tag(opcion.valor)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemFill)))
                }
                
                // Mostrar campo adicional si se seleccionó "Otros" o algo con "cm"
                if necesitaDetalle {
                    AppTextField(
                        title: esNumerico ? "Valor numérico (\(unidadDetectada))" : "Especificar (Otros)",
                        text: bindingDetalle(),
                        placeholder: esNumerico ? "0" : "Escribe aquí...",
                        kind: esNumerico ? .numericWithUnit(unidadDetectada) : .multiline
                    )
                    .padding(.top, 4)
                }
                
            } else if campo.tipoCampo == "number" {
                AppTextField(title: "", text: bindingSingle(), placeholder: "0", kind: .numericWithUnit(""))
            } else {
                // Text
                AppTextField(title: "", text: bindingSingle(), placeholder: "Describe...", kind: .multiline)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var necesitaDetalle: Bool {
        let actuales = (store.draft.caracteres[campo.nombre] ?? "").lowercased()
        return actuales.contains("otr") || actuales.contains("cm") || actuales.contains(" m")
    }
    
    private var esNumerico: Bool {
        let actuales = (store.draft.caracteres[campo.nombre] ?? "").lowercased()
        return actuales.contains("cm") || actuales.contains(" m")
    }
    
    private var unidadDetectada: String {
        let actuales = (store.draft.caracteres[campo.nombre] ?? "").lowercased()
        if actuales.contains("cm") { return "cm" }
        if actuales.contains(" m") { return "m" }
        return ""
    }
    
    private func bindingDetalle() -> Binding<String> {
        Binding(
            get: { store.draft.caracteres["\(campo.nombre)_detalle"] ?? "" },
            set: { store.draft.caracteres["\(campo.nombre)_detalle"] = $0 }
        )
    }
    
    private func bindingSingle() -> Binding<String> {
        Binding(
            get: { store.draft.caracteres[campo.nombre] ?? "" },
            set: { store.draft.caracteres[campo.nombre] = $0 }
        )
    }
    
    private func bindingMulti(_ valor: String) -> Binding<Bool> {
        Binding(
            get: {
                let actuales = store.draft.caracteres[campo.nombre] ?? ""
                return actuales.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.contains(valor)
            },
            set: { isSelected in
                let actuales = store.draft.caracteres[campo.nombre] ?? ""
                var array = actuales.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                
                if isSelected {
                    if !array.contains(valor) { array.append(valor) }
                } else {
                    array.removeAll(where: { $0 == valor })
                }
                store.draft.caracteres[campo.nombre] = array.joined(separator: ", ")
            }
        )
    }
}

// MARK: - Dasométricos (núcleo del paso ÁRBOL) con DAP en vivo

struct DasometricosForm: View {
    @Bindable var store: RegistroWizardStore

    @State private var altura: String = ""
    @State private var cap: String = ""
    @State private var copaParalelo: String = ""
    @State private var copaPerp: String = ""
    @State private var alturaCopa: String = ""

    private var capValor: Double { Double(cap.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var dap: Double { Dasometria.calcularDap(capValor) }

    var body: some View {
        VStack(spacing: 10) {
            AppTextField(title: "Altura total aproximada", text: $altura,
                         placeholder: "0", kind: .numericWithUnit("m"))
                .onChange(of: altura) { _, _ in actualizar() }

            AppTextField(title: "Circunferencia del tallo a 1.30 m (CAP)", text: $cap,
                         placeholder: "0", kind: .numericWithUnit("cm"))
                .onChange(of: cap) { _, _ in actualizar() }

            if store.draft.habito == .arbol {
                // DAP en vivo
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAP calculado")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("DAP = CAP / π")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text("\(Dasometria.formato(dap)) cm")
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.brand)
                        .contentTransition(.numericText())
                        .animation(.default, value: dap)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color.brand.opacity(0.10))
                )
            }

            AppTextField(title: "Diámetro de copa paralelo", text: $copaParalelo,
                         placeholder: "0", kind: .numericWithUnit("m"))
                .onChange(of: copaParalelo) { _, _ in actualizar() }

            AppTextField(title: "Diámetro de copa perpendicular", text: $copaPerp,
                         placeholder: "0", kind: .numericWithUnit("m"))
                .onChange(of: copaPerp) { _, _ in actualizar() }

            AppTextField(title: "Altura de inicio de copa", text: $alturaCopa,
                         placeholder: "0", kind: .numericWithUnit("m"))
                .onChange(of: alturaCopa) { _, _ in actualizar() }
        }
        .onAppear { sincronizar() }
    }

    private func sincronizar() {
        guard let d = store.draft.datosDasometricos else { return }
        if altura.isEmpty       { altura       = format(d.altura) }
        if cap.isEmpty          { cap          = format(d.cap) }
        if copaParalelo.isEmpty { copaParalelo = format(d.diamCopaParalelo) }
        if copaPerp.isEmpty     { copaPerp     = format(d.diamCopaPerpendicular) }
        if alturaCopa.isEmpty   { alturaCopa   = format(d.alturaInicioCopa) }
    }

    private func format(_ v: Double) -> String { v == 0 ? "" : Dasometria.formato(v) }

    private func parse(_ s: String) -> Double {
        Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func actualizar() {
        store.draft.datosDasometricos = DatosDasometricos(
            altura: parse(altura),
            cap: parse(cap),
            diamCopaParalelo: parse(copaParalelo),
            diamCopaPerpendicular: parse(copaPerp),
            alturaInicioCopa: parse(alturaCopa)
        )
    }
}

// MARK: - Acordeón compartido

@ViewBuilder
private func acordeon<Content: View>(
    key: String,
    titulo: String,
    expanded: Binding<Set<String>>,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    DisclosureGroup(
        isExpanded: Binding(
            get: { expanded.wrappedValue.contains(key) },
            set: { value in
                if value { expanded.wrappedValue.insert(key) }
                else { expanded.wrappedValue.remove(key) }
            }
        )
    ) {
        VStack(spacing: 10) { content() }
            .padding(.top, 10)
    } label: {
        Text(titulo).font(.headline)
    }
    .padding(16)
    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
}
