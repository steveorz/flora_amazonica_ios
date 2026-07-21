import Foundation

struct SafeStringDictionary: Decodable {
    var dictionary: [String: String] = [:]
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: DynamicKey.self) {
            for key in container.allKeys {
                if let strValue = try? container.decode(String.self, forKey: key) {
                    dictionary[key.stringValue] = strValue
                } else if let intValue = try? container.decode(Int.self, forKey: key) {
                    dictionary[key.stringValue] = String(intValue)
                } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                    dictionary[key.stringValue] = String(doubleValue)
                } else if let boolValue = try? container.decode(Bool.self, forKey: key) {
                    dictionary[key.stringValue] = String(boolValue)
                }
            }
        }
    }
    
    struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
}
class RealEspecieRepository: EspecieRepository {
    private let apiClient = APIClient.shared
    
    private struct SpeciesRecordDTO: Decodable {
        let id: String
        let scientific_name: String?
        let family: String?
        let habit: String?
        let country_distribution: [String]?
        let status: String?
        let height: Double?
        let crown_diameter: Double?
        let cap: Double?
        let latitude: Double?
        let longitude: Double?
        let morphological_data: MorphologicalDataDTO?
        let tracking_code: String?
        let observation_notes: String?
        let description: String?
        let author_name: String?
        let life_type: String?
        let registrar_id: String?
        let submitted_at: Date?
        let photos: [SpeciesPhotoDTO]?
        
        struct MorphologicalDataDTO: Decodable {
            let dictionary: [String: String]
            
            init(from decoder: Decoder) throws {
                let safeDict = try SafeStringDictionary(from: decoder)
                self.dictionary = safeDict.dictionary
            }
        }
        
        func toEspecie() -> Especie {
            let habitoEnum = Habito(rawValue: habit ?? "") ?? .arbol
            let tipoVidaEnum = TipoVida(rawValue: life_type ?? "") ?? .terrestre
            let estadoEnum = EstadoRegistro(rawValue: status ?? "") ?? .borrador
            
            var datosDaso: DatosDasometricos? = nil
            if let h = height, let cap = cap {
                datosDaso = DatosDasometricos(
                    altura: h,
                    cap: cap,
                    diamCopaParalelo: crown_diameter ?? 0.0,
                    diamCopaPerpendicular: crown_diameter ?? 0.0,
                    alturaInicioCopa: 0.0
                )
            }
            
            var ubic: Ubicacion = Ubicacion(lat: -12.046374, long: -77.042793, referencia: "", altitud: 0.0, tipoHabitat: "") // Default
            if let lat = latitude, let lon = longitude {
                ubic = Ubicacion(lat: lat, long: lon, referencia: "", altitud: 0.0, tipoHabitat: "")
            }
            
            return Especie(
                id: id,
                nombreCientifico: scientific_name ?? "Desconocido",
                autorNombre: author_name ?? "",
                familia: family ?? "Desconocida",
                nombreLocal: observation_notes ?? "",
                habito: habitoEnum,
                tipoVida: tipoVidaEnum,
                distribucionPaises: country_distribution ?? [],
                descripcion: description ?? "",
                caracteres: morphological_data?.dictionary ?? [:],
                datosDasometricos: datosDaso,
                ubicacion: ubic,
                fotos: photos?.compactMap { p in
                    guard let tipo = TipoFoto(rawValue: p.photo_type), let url = URL(string: p.cloudinary_url ?? "") else { return nil }
                    return Foto(id: p.id, tipo: tipo, url: url, autor: "Desconocido", fecha: Date(), localData: nil)
                } ?? [],
                estado: estadoEnum,
                codigoSeguimiento: tracking_code ?? "",
                registradorId: registrar_id ?? "",
                fechaEnvio: submitted_at ?? Date(),
                historialEstados: []
            )
        }
    }
    
    private struct SpeciesPhotoDTO: Decodable {
        let id: String
        let photo_type: String
        let cloudinary_url: String?
    }
    
    private struct CreateSpeciesDTO: Encodable {
        let scientific_name: String
        let family: String
        let habit: String
        let country_distribution: [String]?
        let height: Double?
        let crown_diameter: Double?
        let cap: Double?
        let dap: Double?
        let longitude: Double?
        let latitude: Double?
        let morphological_data: [String: String]?
        let is_draft: Bool
        let author_name: String?
        let observation_notes: String?
        let life_type: String?
        let description: String?
        let species_catalog_id: String?
    }
    
    private struct SpeciesCatalogDTO: Decodable {
        let id: String
        let scientific_name: String?
        let family: String?
        let is_active: Bool?
        
        func toEspecie() -> Especie {
            return Especie(
                id: id,
                catalogId: id,
                nombreCientifico: scientific_name ?? "Desconocido",
                autorNombre: "",
                familia: family ?? "Desconocida",
                nombreLocal: "Sin nombre común",
                habito: .arbol,
                tipoVida: .terrestre,
                distribucionPaises: [],
                descripcion: "Especie base del catálogo oficial importado.",
                caracteres: [:],
                datosDasometricos: nil,
                ubicacion: Ubicacion(lat: 0.0, long: 0.0, referencia: "", altitud: 0.0, tipoHabitat: ""),
                fotos: [],
                estado: (is_active ?? true) ? .validado : .borrador,
                codigoSeguimiento: "CAT-\(id.prefix(6))",
                registradorId: "",
                fechaEnvio: .now,
                historialEstados: []
            )
        }
    }
    
    private struct EmptyResponse: Decodable {}
    
    private struct PaginatedResponse<T: Decodable>: Decodable {
        let data: [T]
    }
    
    private func fetchAllMerged() async throws -> [Especie] {
        var records: [SpeciesRecordDTO] = []
        do {
            records = try await apiClient.request(endpoint: "/especies")
        } catch {
            print("=== ERROR OBTENIENDO /especies ===")
            print(error)
            print("===========================================")
        }
        
        var catalog: [SpeciesCatalogDTO] = []
        do {
            catalog = try await apiClient.request(endpoint: "/catalogo/especies")
        } catch {
            print("=== ERROR OBTENIENDO /catalogo/especies ===")
            print(error)
            print("===========================================")
        }
        
        var publicRecords: [SpeciesRecordDTO] = []
        do {
            let res: PaginatedResponse<SpeciesRecordDTO> = try await apiClient.request(endpoint: "/catalogo/buscar?limit=100")
            publicRecords = res.data
        } catch {
            print("=== ERROR OBTENIENDO /catalogo/buscar ===")
            print(error)
            print("===========================================")
        }
        
        var uniqueRecords: [SpeciesRecordDTO] = []
        var seenIds: Set<String> = []
        for r in records + publicRecords {
            if !seenIds.contains(r.id) {
                seenIds.insert(r.id)
                uniqueRecords.append(r)
            }
        }
        
        let especiesRecords = uniqueRecords.map { $0.toEspecie() }
        let especiesCatalog = catalog.map { $0.toEspecie() }
        
        return especiesRecords + especiesCatalog
    }

    func listar() async throws -> [Especie] {
        return try await fetchAllMerged()
    }
    
    func buscar(query: String) async throws -> [Especie] {
        let todas = try await fetchAllMerged()
        let q = query.lowercased()
        return todas.filter { especie in
            especie.nombreCientifico.lowercased().contains(q) ||
            especie.familia.lowercased().contains(q) ||
            especie.codigoSeguimiento.lowercased().contains(q) ||
            especie.nombreLocal.lowercased().contains(q)
        }
    }
    
    func get(id: String) async throws -> Especie {
        // First try to fetch from user records
        if let record: SpeciesRecordDTO = try? await apiClient.request(endpoint: "/especies/\(id)") {
            return record.toEspecie()
        }
        // If not found (or it's a catalog ID), fallback to the full list to find it
        let todas = try await fetchAllMerged()
        if let found = todas.first(where: { $0.id == id }) {
            return found
        }
        throw NSError(domain: "RealEspecieRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Especie no encontrada"])
    }
    
    func listarPorRegistrador(_ usuarioId: String) async throws -> [Especie] {
        let todas = try await fetchAllMerged()
        return todas.filter { $0.registradorId == usuarioId }
    }
    
    func crear(_ especie: Especie) async throws -> Especie {
        var morphData = especie.caracteres
        if !especie.nombreLocal.isEmpty {
            morphData["local_name"] = especie.nombreLocal
        }
        
        let dto = CreateSpeciesDTO(
            scientific_name: especie.nombreCientifico,
            family: especie.familia,
            habit: especie.habito.rawValue,
            country_distribution: especie.distribucionPaises,
            height: especie.datosDasometricos?.altura,
            crown_diameter: especie.datosDasometricos?.diamCopaParalelo,
            cap: especie.datosDasometricos?.cap,
            dap: especie.datosDasometricos?.cap, // Assuming DAP might be CAP or derived, using cap here as fallback
            longitude: especie.ubicacion.long,
            latitude: especie.ubicacion.lat,
            morphological_data: morphData,
            is_draft: especie.estado == .borrador,
            author_name: especie.autorNombre.isEmpty ? nil : especie.autorNombre,
            observation_notes: nil,
            life_type: especie.tipoVida.rawValue,
            description: especie.descripcion.isEmpty ? nil : especie.descripcion,
            species_catalog_id: especie.catalogId
        )
        let bodyData = try? JSONEncoder().encode(dto)
        let record: SpeciesRecordDTO = try await apiClient.request(endpoint: "/especies", method: "POST", body: bodyData)
        
        // Subir fotos
        for foto in especie.fotos {
            if let fotoData = foto.localData {
                let params = [
                    "species_record_id": record.id,
                    "photo_type": foto.tipo.rawValue
                ]
                let fileName = "foto_\(foto.tipo.rawValue).jpg"
                do {
                    let _: EmptyResponse = try await apiClient.uploadMultipart(
                        endpoint: "/especies/fotos",
                        fileData: fotoData,
                        fileName: fileName,
                        mimeType: "image/jpeg",
                        parameters: params
                    )
                } catch {
                    print("Error uploading photo \(foto.tipo.rawValue): \(error)")
                }
            }
        }
        
        return record.toEspecie()
    }
    
    func actualizar(_ especie: Especie) async throws -> Especie {
        var morphData = especie.caracteres
        if !especie.nombreLocal.isEmpty {
            morphData["local_name"] = especie.nombreLocal
        }
        
        let dto = CreateSpeciesDTO(
            scientific_name: especie.nombreCientifico,
            family: especie.familia,
            habit: especie.habito.rawValue,
            country_distribution: especie.distribucionPaises,
            height: especie.datosDasometricos?.altura,
            crown_diameter: especie.datosDasometricos?.diamCopaParalelo,
            cap: especie.datosDasometricos?.cap,
            dap: especie.datosDasometricos?.cap,
            longitude: especie.ubicacion.long,
            latitude: especie.ubicacion.lat,
            morphological_data: morphData,
            is_draft: especie.estado == .borrador,
            author_name: especie.autorNombre.isEmpty ? nil : especie.autorNombre,
            observation_notes: nil,
            life_type: especie.tipoVida.rawValue,
            description: especie.descripcion.isEmpty ? nil : especie.descripcion,
            species_catalog_id: especie.catalogId
        )
        let bodyData = try? JSONEncoder().encode(dto)
        let record: SpeciesRecordDTO = try await apiClient.request(endpoint: "/especies/\(especie.id)", method: "PATCH", body: bodyData)
        
        // Subir fotos
        for foto in especie.fotos {
            if let fotoData = foto.localData {
                let params = [
                    "species_record_id": record.id,
                    "photo_type": foto.tipo.rawValue
                ]
                let fileName = "foto_\(foto.tipo.rawValue).jpg"
                do {
                    let _: EmptyResponse = try await apiClient.uploadMultipart(
                        endpoint: "/especies/fotos",
                        fileData: fotoData,
                        fileName: fileName,
                        mimeType: "image/jpeg",
                        parameters: params
                    )
                } catch {
                    print("Error uploading photo \(foto.tipo.rawValue): \(error)")
                }
            }
        }
        
        return record.toEspecie()
    }
    
    func eliminar(id: String) async throws {
        let _ : [String: String]? = try? await apiClient.request(endpoint: "/especies/\(id)", method: "DELETE")
    }
}
