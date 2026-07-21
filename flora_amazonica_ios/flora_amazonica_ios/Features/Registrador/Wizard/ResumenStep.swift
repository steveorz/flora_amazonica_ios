import SwiftUI

/// R-13: resumen previo al envío. 'Editar' salta al paso correspondiente.
struct ResumenStep: View {

    @Bindable var store: RegistroWizardStore
    var onEditar: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                seccion("Identificación", paso: 1) {
                    fila("Nombre", store.draft.nombreCientifico, italic: true)
                    fila("Autor", store.draft.autorNombre)
                    fila("Familia", store.draft.familia)
                    fila("Nombre local", store.draft.nombreLocal)
                    fila("Distribución", store.draft.distribucionPaises.joined(separator: ", "))
                }

                seccion("Hábito", paso: 2) {
                    fila("Hábito", store.draft.habito?.label ?? "—")
                    fila("Tipo de vida", store.draft.tipoVida?.label ?? "—")
                }

                if let d = store.draft.datosDasometricos, (store.draft.habito == .arbol || store.draft.habito == .palmera) {
                    seccion("Dasométricos", paso: 3) {
                        fila("Altura", "\(Dasometria.formato(d.altura)) m")
                        fila("CAP",    "\(Dasometria.formato(d.cap)) cm")
                        if store.draft.habito == .arbol {
                            fila("DAP",    "\(Dasometria.formato(d.dap)) cm")
                        }
                    }
                }

                if !store.draft.caracteres.isEmpty {
                    seccion("Caracteres morfológicos", paso: 3) {
                        ForEach(store.draft.caracteres.sorted(by: { $0.key < $1.key }), id: \.key) { key, v in
                            fila(key.capitalized, v)
                        }
                    }
                }

                if let ub = store.draft.ubicacion {
                    seccion("Ubicación", paso: 4) {
                        fila("Coordenadas",
                             "\(String(format: "%.4f", ub.lat)), \(String(format: "%.4f", ub.long))")
                        fila("Hábitat", ub.tipoHabitat)
                        if !ub.referencia.isEmpty {
                            fila("Referencia", ub.referencia)
                        }
                    }
                }

                seccion("Fotos", paso: 5) {
                    fila("Capturadas",
                         "\(store.draft.fotosCapturadas.count) de \(TipoFoto.allCases.count)")
                }

                if let err = store.errorEnvio {
                    Text(err)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Resumen")
                .font(.title2.weight(.bold))
            Text("Revisa todo antes de enviar al validador.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func seccion<Content: View>(
        _ titulo: String,
        paso: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(titulo).font(.headline)
                Spacer()
                Button("Editar") { onEditar(paso) }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brand)
            }
            VStack(alignment: .leading, spacing: 6) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private func fila(_ label: String, _ value: String, italic: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(italic ? .body.italic() : .body)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
