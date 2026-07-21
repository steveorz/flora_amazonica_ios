import SwiftUI

/// Editor del catálogo de valores morfológicos.
/// Permite ver, alternar activos, crear y borrar entradas.
struct ValoresMorfologicosView: View {

    @Environment(ValorMorfologicoService.self) private var servicio
    @State private var categoriaSeleccionada: String?
    @State private var sheetNuevo = false
    @State private var pendienteEliminar: ValorMorfologico?
    @State private var toast: ToastInfo?

    var body: some View {
        Group {
            if servicio.loading && servicio.valores.isEmpty {
                cargando
            } else if let kind = servicio.error, servicio.valores.isEmpty {
                ErrorState(kind: kind) {
                    Task { await servicio.cargar() }
                }
            } else if servicio.valores.isEmpty {
                EmptyState(
                    systemImage: "circle.hexagongrid",
                    title: "Sin valores cargados",
                    message: "Crea el primer valor para empezar a categorizar."
                )
            } else {
                contenido
            }
        }
        .navigationTitle("Valores morfológicos")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sheetNuevo = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            if servicio.valores.isEmpty { await servicio.cargar() }
            if categoriaSeleccionada == nil { categoriaSeleccionada = servicio.categorias.first }
        }
        .refreshable { await servicio.cargar() }
        .sheet(isPresented: $sheetNuevo) {
            NuevoValorMorfologicoSheet(
                categoriasExistentes: servicio.categorias,
                categoriaPrellenada: categoriaSeleccionada
            ) { nuevo in
                await servicio.crear(nuevo)
                categoriaSeleccionada = nuevo.categoria
                toast = ToastInfo(kind: .exito, message: "Valor creado.")
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog(
            "¿Eliminar este valor?",
            isPresented: Binding(
                get: { pendienteEliminar != nil },
                set: { if !$0 { pendienteEliminar = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if let v = pendienteEliminar {
                    Task {
                        await servicio.eliminar(codigo: v.codigo)
                        toast = ToastInfo(kind: .exito, message: "Valor eliminado.")
                    }
                }
                pendienteEliminar = nil
            }
            Button("Cancelar", role: .cancel) { pendienteEliminar = nil }
        } message: {
            if let v = pendienteEliminar {
                Text("Se borrará \"\(v.nombre)\" del catálogo de \(v.categoria.lowercased()).")
            }
        }
        .overlay(alignment: .top) {
            if let t = toast {
                AppToast(kind: t.kind, message: t.message)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        toast = nil
                    }
            }
        }
    }

    private var contenido: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(servicio.categorias, id: \.self) { cat in
                        chipCategoria(cat)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            if let cat = categoriaSeleccionada {
                let items = servicio.enCategoria(cat)
                if items.isEmpty {
                    EmptyState(
                        systemImage: "tray",
                        title: "Categoría vacía",
                        message: "Crea valores para \(cat.lowercased())."
                    )
                } else {
                    List {
                        ForEach(items) { v in
                            row(v)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }

    private func chipCategoria(_ cat: String) -> some View {
        let isOn = categoriaSeleccionada == cat
        return Button {
            categoriaSeleccionada = cat
        } label: {
            Text(cat)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(isOn ? Color.onBrand : Color.primary)
                .glassEffect(
                    isOn ? .regular.tint(Color.brand).interactive() : .regular.interactive(),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private func row(_ v: ValorMorfologico) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(v.activo ? Color.navigationSelection.opacity(0.18) : Color.gray.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(v.orden))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(v.activo ? Color.navigationSelection : .secondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(v.nombre)
                    .font(.subheadline.weight(.semibold))
                Text(v.codigo)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { v.activo },
                set: { _ in Task { await servicio.toggleActivo(v) } }
            ))
            .labelsHidden()
            .tint(Color.navigationSelection)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                pendienteEliminar = v
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }

    private var cargando: some View {
        VStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in
                LoadingSkeleton(cornerRadius: 12).frame(height: 56)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private struct ToastInfo: Identifiable {
        let id = UUID()
        let kind: AppToastKind
        let message: String
    }
}

// MARK: - Crear nuevo valor

struct NuevoValorMorfologicoSheet: View {

    let categoriasExistentes: [String]
    let categoriaPrellenada: String?
    let onCrear: (ValorMorfologico) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var categoria: String = ""
    @State private var nombre: String = ""
    @State private var enviando = false

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Nuevo valor")
                .font(.title3.weight(.semibold))

            VStack(spacing: 12) {
                AppTextField(
                    title: "Categoría",
                    text: $categoria,
                    placeholder: "Ej. Color de fruto"
                )

                if !categoriasExistentes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categoriasExistentes, id: \.self) { c in
                                Button {
                                    categoria = c
                                } label: {
                                    Text(c)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .foregroundStyle(.primary)
                                        .glassEffect(.regular.interactive(), in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                AppTextField(
                    title: "Nombre",
                    text: $nombre,
                    placeholder: "Ej. Verde claro"
                )
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 4)

            VStack(spacing: 10) {
                AppButton(enviando ? "Guardando…" : "Crear valor",
                          variant: .atencion) {
                    Task {
                        enviando = true
                        let codigo = "\(slug(categoria)).\(slug(nombre)).\(Int(Date().timeIntervalSince1970))"
                        let v = ValorMorfologico(
                            categoria: categoria.trimmingCharacters(in: .whitespaces),
                            nombre: nombre.trimmingCharacters(in: .whitespaces),
                            codigo: codigo,
                            orden: 999,
                            activo: true
                        )
                        await onCrear(v)
                        enviando = false
                        dismiss()
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!formValido || enviando)

                AppButton("Cancelar", variant: .terciario) {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
        .background(Color.appBackground)
        .onAppear {
            if let p = categoriaPrellenada { categoria = p }
        }
    }

    private var formValido: Bool {
        !categoria.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func slug(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}
