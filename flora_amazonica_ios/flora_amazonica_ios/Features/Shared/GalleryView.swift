import SwiftUI

/// Pantalla temporal de QA visual: muestra todos los componentes de cristal
/// y la lista de especies mock usando SpeciesCard.
struct GalleryView: View {

    @Environment(EspecieService.self) private var especies

    // Estados de demo para los controles
    @State private var menuSel: String? = nil
    @State private var radioSel: Habito? = .arbol
    @State private var checkSel: Set<String> = []
    @State private var chipSel: Set<String> = ["Loreto"]
    @State private var switchOn: Bool = true
    @State private var fecha: Date = .now
    @State private var texto: String = ""
    @State private var numero: String = ""
    @State private var clave: String = ""
    @State private var notas: String = ""

    private let chipsItems = ["Loreto", "Ucayali", "Madre de Dios", "San Martín", "Amazonas"]
    private let menuItems  = ["Tierra firme", "Várzea", "Igapó", "Aguajal"]
    private let checkItems = ["Hoja", "Flor", "Fruto", "Corteza"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                section("Buttons") { buttonsDemo }
                section("Text fields") { textFieldsDemo }
                section("Menu / Dropdown") {
                    AppMenu(title: "Tipo de hábitat",
                            items: menuItems,
                            selection: $menuSel,
                            labelFor: { $0 })
                }
                section("Radio") {
                    AppRadioGroup(
                        title: "Hábito",
                        items: Habito.allCases,
                        selection: $radioSel,
                        labelFor: { $0.label }
                    )
                }
                section("Checkbox") {
                    AppCheckboxGroup(
                        title: "Material colectado",
                        items: checkItems,
                        selection: $checkSel,
                        labelFor: { $0 }
                    )
                }
                section("Chips") {
                    AppChips(items: chipsItems, selection: $chipSel, labelFor: { $0 })
                }
                section("Switch / DatePicker") {
                    VStack(spacing: 12) {
                        AppSwitch(title: "Compartir ubicación precisa", isOn: $switchOn)
                        AppDatePicker(title: "Fecha de registro", date: $fecha)
                    }
                }
                section("Estado badges") { estadosDemo }
                section("Glass card") {
                    GlassCard(tint: .brand) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tarjeta flotante de cristal")
                                .font(.headline)
                            Text("Úsala para acciones u overlays — nunca para listas o fichas.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                section("Progress stepper") {
                    ProgressStepper(current: 2, total: 5)
                }
                section("Toasts") { toastsDemo }
                section("Loading skeleton") {
                    VStack(spacing: 8) {
                        LoadingSkeleton().frame(height: 18)
                        LoadingSkeleton().frame(height: 18).frame(maxWidth: 220)
                        LoadingSkeleton(cornerRadius: 14).frame(height: 80)
                    }
                }
                section("Empty state") {
                    EmptyState(
                        systemImage: "tray",
                        title: "Sin resultados",
                        message: "No encontramos especies con esos filtros.",
                        actionTitle: "Limpiar filtros",
                        action: {}
                    )
                    .frame(height: 220)
                }
                section("Error state") {
                    ErrorState(kind: .sinConexion, onRetry: {})
                        .frame(height: 220)
                }
                section("SpeciesCard — mini") { speciesMini }
                section("SpeciesCard — galería") { speciesGaleria }
                section("SpeciesCard — lista") { speciesLista }
            }
            .padding(20)
        }
        .navigationTitle("Galería de componentes")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            content()
        }
    }

    @ViewBuilder
    private var buttonsDemo: some View {
        VStack(spacing: 10) {
            AppButton("Primario", systemImage: "checkmark", variant: .primario, action: {})
                .frame(maxWidth: .infinity)
            AppButton("Acción protagonista", systemImage: "plus.circle.fill", variant: .atencion, action: {})
                .frame(maxWidth: .infinity)
            AppButton("Secundario", systemImage: "square.and.arrow.up", variant: .secundario, action: {})
                .frame(maxWidth: .infinity)
            AppButton("Terciario", variant: .terciario, action: {})
                .frame(maxWidth: .infinity)
            AppButton("Eliminar", systemImage: "trash", variant: .destructivo, action: {})
                .frame(maxWidth: .infinity)
            HStack(spacing: 10) {
                AppButton(systemImage: "heart", variant: .icono, action: {})
                AppButton(systemImage: "bell", variant: .icono, action: {})
                AppButton(systemImage: "ellipsis", variant: .icono, action: {})
            }
        }
    }

    @ViewBuilder
    private var textFieldsDemo: some View {
        VStack(spacing: 10) {
            AppTextField(title: "Texto", text: $texto, placeholder: "Nombre local")
            AppTextField(title: "Numérico con unidad",
                         text: $numero,
                         placeholder: "0",
                         kind: .numericWithUnit("cm"))
            AppTextField(title: "Contraseña", text: $clave, kind: .password)
            AppTextField(title: "Multilínea",
                         text: $notas,
                         placeholder: "Observaciones de campo…",
                         kind: .multiline)
        }
    }

    @ViewBuilder
    private var estadosDemo: some View {
        FlowH(spacing: 8) {
            ForEach(EstadoRegistro.allCases, id: \.self) { estado in
                EstadoBadge(estado: estado)
            }
        }
    }

    @ViewBuilder
    private var toastsDemo: some View {
        VStack(spacing: 10) {
            AppToast(kind: .exito, message: "Registro guardado correctamente.")
            AppToast(kind: .error, message: "No se pudo subir la foto.")
            AppToast(kind: .info,  message: "Trabajando sin conexión.")
        }
    }

    // MARK: - Species

    @ViewBuilder
    private var speciesMini: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(especies.especies.prefix(4)) { e in
                SpeciesCard(especie: e, variant: .mini)
            }
        }
    }

    @ViewBuilder
    private var speciesGaleria: some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        LazyVGrid(columns: cols, spacing: 12) {
            ForEach(especies.especies.prefix(6)) { e in
                SpeciesCard(especie: e, variant: .galeria)
            }
        }
    }

    @ViewBuilder
    private var speciesLista: some View {
        VStack(spacing: 0) {
            ForEach(especies.especies) { e in
                SpeciesCard(especie: e, variant: .lista)
                Divider()
            }
        }
    }
}

/// Layout horizontal con wrap simple para los badges de demo.
private struct FlowH: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, totalW: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth, x > 0 {
                y += rowH + spacing; x = 0; rowH = 0
            }
            x += s.width + spacing
            totalW = max(totalW, x)
            rowH = max(rowH, s.height)
        }
        return CGSize(width: totalW, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX {
                y += rowH + spacing; x = bounds.minX; rowH = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: s.width, height: s.height))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
