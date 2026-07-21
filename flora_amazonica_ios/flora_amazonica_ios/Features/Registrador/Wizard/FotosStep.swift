import SwiftUI
import PhotosUI

/// R-12: 5 fotos obligatorias (una por tipo) con PhotosPicker.
struct FotosStep: View {

    @Bindable var store: RegistroWizardStore

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(TipoFoto.allCases, id: \.self) { tipo in
                        FotoSlotView(tipo: tipo, store: store)
                    }
                }

                contador
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Fotografías")
                .font(.title2.weight(.bold))
            Text("Captura una foto por cada tipo. Toca cualquier foto para reemplazarla.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var contador: some View {
        let total = TipoFoto.allCases.count
        let n = store.draft.fotosCapturadas.count
        return HStack {
            Image(systemName: n == total ? "checkmark.circle.fill" : "photo.stack")
                .foregroundStyle(n == total ? .green : .secondary)
            Text("\(n) de \(total) fotos capturadas")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Slot por tipo de foto

struct FotoSlotView: View {

    let tipo: TipoFoto
    @Bindable var store: RegistroWizardStore

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: Image?

    private var capturada: Bool { store.draft.fotosCapturadas.contains(tipo) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tipo.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                contenido
            }
            .onChange(of: pickerItem) { _, new in
                cargar(new)
            }
            .onAppear { cargarMemoria() }
        }
    }

    @ViewBuilder
    private var contenido: some View {
        ZStack {
            if let image {
                // Color.clear fija el layout 1:1; la foto solo rellena y se recorta.
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        image
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else if capturada {
                Rectangle()
                    .fill(Color.brand.opacity(0.18))
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.title)
                            .foregroundStyle(Color.brand)
                    )
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Tocar para agregar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
                    .aspectRatio(1, contentMode: .fit)
            }

            if capturada {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.onBrand, Color.brand)
                            .padding(6)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }

    private func cargarMemoria() {
        if image != nil { return }
        
        var finalData: Data? = store.fotoData[tipo]
        
        if finalData == nil, capturada {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("draft_\(store.draft.id)_\(tipo.rawValue).jpg")
            if let diskData = try? Data(contentsOf: url) {
                finalData = diskData
                store.fotoData[tipo] = diskData
            }
        }
        
        guard let data = finalData, let uiImage = UIImage(data: data) else { return }
        image = Image(uiImage: uiImage)
    }

    private func cargar(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let rawData = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: rawData) {
                
                // HACK: Redimensionar imagen a máximo 1280px por lado para asegurar que el peso
                // sea siempre menor a 2MB y no exceda el límite de 10MB del backend (que rechaza silenciosamente).
                let maxDim: CGFloat = 1280
                var finalImage = uiImage
                if uiImage.size.width > maxDim || uiImage.size.height > maxDim {
                    let ratio = min(maxDim / uiImage.size.width, maxDim / uiImage.size.height)
                    let newSize = CGSize(width: uiImage.size.width * ratio, height: uiImage.size.height * ratio)
                    if let resized = uiImage.preparingThumbnail(of: newSize) {
                        finalImage = resized
                    }
                }
                
                if let jpegData = finalImage.jpegData(compressionQuality: 0.7) {
                    // Guardar en disco para evitar pérdida si se retoma el borrador
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("draft_\(store.draft.id)_\(tipo.rawValue).jpg")
                    try? jpegData.write(to: url)
                    
                    await MainActor.run {
                        store.fotoData[tipo] = jpegData
                        store.draft.fotosCapturadas.insert(tipo)
                        image = Image(uiImage: finalImage)
                    }
                }
            }
        }
    }
}
