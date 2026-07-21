import Foundation
import Observation
import SwiftUI

/// Estado observable del wizard de nuevo registro.
/// - `draft` tiene los datos persistibles.
/// - `fotoData` tiene las imágenes capturadas en memoria (no se persisten en borrador).
@MainActor
@Observable
final class RegistroWizardStore {

    var draft: EspecieDraft
    /// Datos crudos de imagen por tipo. No se persiste en JSON de borrador.
    var fotoData: [TipoFoto: Data] = [:]
    var pasoActual: Int = 1
    let totalPasos: Int = 7

    /// Si es edición, el id del registro existente que se está modificando.
    let editandoId: String?

    var enviando: Bool = false
    var errorEnvio: String?
    var resultado: Especie?
    
    // MARK: - Formulario Dinámico
    var camposDinamicos: [CampoMorfologico] = []
    var cargandoCampos: Bool = false
    var errorCampos: String?
    var habitoCargado: String?

    init() {
        self.draft = EspecieDraft()
        self.editandoId = nil
    }

    init(draft: EspecieDraft) {
        self.draft = draft
        self.pasoActual = max(1, min(draft.pasoActual, totalPasos))
        self.editandoId = nil
    }

    init(especie: Especie) {
        self.draft = EspecieDraft(from: especie)
        self.editandoId = especie.id
        // En edición, las fotos ya existen como URLs; las marcamos como capturadas
        // pero la captura desde el wizard puede sobreescribir.
        self.draft.fotosCapturadas = Set(especie.fotos.map(\.tipo))
    }

    // MARK: - Navegación

    func avanzar() {
        pasoActual = min(pasoActual + 1, totalPasos)
        draft.pasoActual = pasoActual
        guardarBorradorLocal()
    }

    func retroceder() {
        pasoActual = max(pasoActual - 1, 1)
        draft.pasoActual = pasoActual
    }

    func irA(_ paso: Int) {
        pasoActual = max(1, min(paso, totalPasos))
        draft.pasoActual = pasoActual
    }
    
    // MARK: - Formulario Dinámico
    
    func cargarCamposDinamicos(habito: String) async {
        cargandoCampos = true
        errorCampos = nil
        do {
            let repo = RealValorMorfologicoRepository()
            camposDinamicos = try await repo.obtenerCamposDinamicos(habito: habito)
            habitoCargado = habito
        } catch {
            errorCampos = "Error al cargar el formulario: \(error.localizedDescription)"
        }
        cargandoCampos = false
    }

    // MARK: - Borrador

    func guardarBorradorLocal() {
        draft.fechaActualizacion = .now
        DraftStorage.upsert(draft)
    }

    func descartarBorrador() {
        DraftStorage.delete(id: draft.id)
    }

    // MARK: - Envío

    func enviar(registradorId: String, service: EspecieService) async {
        enviando = true
        errorEnvio = nil
        defer { enviando = false }

        guard let habito = draft.habito,
              let tipoVida = draft.tipoVida,
              let ubicacion = draft.ubicacion
        else {
            errorEnvio = "Faltan datos obligatorios."
            return
        }

        let codigo = editandoId.flatMap { _ in nil as String? }
            ?? "FAM-2025-\(String(format: "%05d", Int.random(in: 10000...99999)))"

        let fotos = generarFotos(scientificName: draft.nombreCientifico)
        let ahora = Date()

        do {
            if let editandoId {
                let actualizado = try await service.get(id: editandoId)
                var nuevo = actualizado
                nuevo.catalogId = draft.catalogId
                nuevo.nombreCientifico = draft.nombreCientifico
                nuevo.autorNombre = draft.autorNombre
                nuevo.familia = draft.familia
                nuevo.nombreLocal = draft.nombreLocal
                nuevo.habito = habito
                nuevo.tipoVida = tipoVida
                nuevo.distribucionPaises = draft.distribucionPaises
                nuevo.descripcion = draft.descripcion
                nuevo.caracteres = draft.caracteres
                nuevo.datosDasometricos = draft.datosDasometricos
                nuevo.ubicacion = ubicacion
                if !fotos.isEmpty { nuevo.fotos = fotos }
                nuevo.historialEstados.append(
                    HistorialEstado(
                        id: UUID().uuidString,
                        estado: nuevo.estado,
                        fecha: ahora,
                        usuarioId: registradorId,
                        comentario: "Editado por el registrador"
                    )
                )
                resultado = try await service.actualizar(nuevo)
            } else {
                let especie = Especie(
                    id: draft.id,
                    catalogId: draft.catalogId,
                    nombreCientifico: draft.nombreCientifico,
                    autorNombre: draft.autorNombre,
                    familia: draft.familia,
                    nombreLocal: draft.nombreLocal,
                    habito: habito,
                    tipoVida: tipoVida,
                    distribucionPaises: draft.distribucionPaises,
                    descripcion: draft.descripcion,
                    caracteres: draft.caracteres,
                    datosDasometricos: draft.datosDasometricos,
                    ubicacion: ubicacion,
                    fotos: fotos,
                    estado: .enRevision,
                    codigoSeguimiento: codigo,
                    registradorId: registradorId,
                    fechaEnvio: ahora,
                    historialEstados: [
                        HistorialEstado(
                            id: UUID().uuidString,
                            estado: .enRevision,
                            fecha: ahora,
                            usuarioId: registradorId,
                            comentario: nil
                        )
                    ]
                )
                resultado = try await service.crear(especie)
                descartarBorrador()
            }
        } catch let apiError as APIError {
            errorEnvio = apiError.localizedDescription
        } catch {
            errorEnvio = "No se pudo enviar el registro."
        }
    }

    // MARK: - Validaciones por paso

    func pasoCompleto(_ paso: Int) -> Bool {
        switch paso {
        case 1: // Identificación
            return !draft.nombreCientifico.isEmpty &&
                   !draft.familia.isEmpty &&
                   !draft.nombreLocal.isEmpty &&
                   !draft.distribucionPaises.isEmpty
        case 2: // Hábito y tipo de vida
            return draft.habito != nil && draft.tipoVida != nil
        case 3: // Morfología
            return !draft.caracteres.isEmpty ||
                   ((draft.habito == .arbol || draft.habito == .palmera) && draft.datosDasometricos != nil)
        case 4: // Ubicación
            return draft.ubicacion != nil &&
                   !(draft.ubicacion?.tipoHabitat.isEmpty ?? true)
        case 5: // Fotos
            return draft.fotosCapturadas.count >= TipoFoto.allCases.count
        case 6, 7:
            return true
        default:
            return false
        }
    }

    // MARK: - Helpers

    private func generarFotos(scientificName: String) -> [Foto] {
        let slug = scientificName.replacingOccurrences(of: " ", with: "+")
        return draft.fotosCapturadas.sorted(by: { $0.rawValue < $1.rawValue }).map { tipo in
            
            var dataToUpload = fotoData[tipo]
            if dataToUpload == nil {
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("draft_\(draft.id)_\(tipo.rawValue).jpg")
                if let diskData = try? Data(contentsOf: url) {
                    dataToUpload = diskData
                    fotoData[tipo] = diskData
                }
            }
            
            return Foto(
                id: UUID().uuidString,
                tipo: tipo,
                url: URL(string: "https://placehold.co/600x600/2D6A4F/FFFFFF.png?text=\(slug)+\(tipo.rawValue)")!,
                autor: "Registrador",
                fecha: .now,
                localData: dataToUpload
            )
        }
    }
}
