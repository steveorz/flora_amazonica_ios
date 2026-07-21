import Foundation

class RealValorMorfologicoRepository: ValorMorfologicoRepository {
    private let apiClient = APIClient.shared
    
    private struct MorphologicalValueDTO: Codable {
        let id: String
        let habit: String?
        let section: String?
        let field_name: String?
        let option_value: String?
        let selection_type: String?
        let is_required: Bool?
        let display_order: Int?
        let is_active: Bool?
        let field_type: String?
        
        func toValorMorfologico() -> ValorMorfologico {
            return ValorMorfologico(
                categoria: section ?? "",
                nombre: field_name ?? "",
                codigo: id,
                orden: display_order ?? 0,
                activo: is_active ?? true
            )
        }
    }
    
    private struct CreateMorphologicalValueDTO: Codable {
        let habit: String
        let section: String
        let field_name: String
        let option_value: String
        let selection_type: String
        let is_required: Bool
        let display_order: Int
        let is_active: Bool
    }
    
    private struct ToggleStatusDTO: Codable {
        let is_active: Bool
    }
    
    func listar() async throws -> [ValorMorfologico] {
        let dtos: [MorphologicalValueDTO] = try await apiClient.request(endpoint: "/morfologia")
        return dtos.map { $0.toValorMorfologico() }
    }
    
    func obtenerCamposDinamicos(habito: String) async throws -> [CampoMorfologico] {
        // Pedimos todos los campos sin filtro de hábito en la URL, porque el backend
        // tiene un bug con la sensibilidad a los acentos (ej. "Árbol" vs "arbol")
        let dtos: [MorphologicalValueDTO] = try await apiClient.request(endpoint: "/morfologia")
        
        let habitoNormalizado = habito.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        
        // 1. Filtrar activos y que el hábito coincida ignorando acentos y mayúsculas
        let filtrados = dtos.filter { dto in
            guard let dtoHabit = dto.habit else { return false }
            let dtoHabito = dtoHabit.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return (dto.is_active ?? true) && dtoHabito == habitoNormalizado
        }
        
        // 2. Agrupar por sección y luego por field_name
        var camposDict: [String: CampoMorfologico] = [:]
        
        for dto in filtrados {
            guard let section = dto.section, let fieldName = dto.field_name, let optionValue = dto.option_value else { continue }
            let key = "\(section)-\(fieldName)"
            let opcion = OpcionMorfologica(id: dto.id, valor: optionValue, orden: dto.display_order ?? 0)
            
            if var campo = camposDict[key] {
                // Si el option_value no está vacío ni es "N/A", lo agregamos
                if !optionValue.trimmingCharacters(in: .whitespaces).isEmpty && optionValue != "N/A" {
                    campo.opciones.append(opcion)
                }
                camposDict[key] = campo
            } else {
                // Determinar el fieldType de forma segura
                let ft = dto.field_type ?? "option"
                
                var opciones: [OpcionMorfologica] = []
                if !optionValue.trimmingCharacters(in: .whitespaces).isEmpty && optionValue != "N/A" {
                    opciones.append(opcion)
                }
                
                let campo = CampoMorfologico(
                    seccion: section,
                    nombre: fieldName,
                    tipoSeleccion: dto.selection_type ?? "single",
                    tipoCampo: ft,
                    requerido: dto.is_required ?? false,
                    orden: dto.display_order ?? 0,
                    opciones: opciones
                )
                camposDict[key] = campo
            }
        }
        
        // 3. Ordenar opciones dentro de cada campo, y devolver los campos ordenados por orden (o alfabético)
        let camposOrdenados = camposDict.values.map { campo -> CampoMorfologico in
            var c = campo
            c.opciones.sort { $0.orden < $1.orden }
            return c
        }.sorted { $0.orden < $1.orden }
        
        return camposOrdenados
    }
    
    func crear(_ valor: ValorMorfologico) async throws {
        let dto = CreateMorphologicalValueDTO(
            habit: "Árbol", // Placeholder para Admin
            section: valor.categoria,
            field_name: valor.nombre,
            option_value: "N/A",
            selection_type: "single",
            is_required: false,
            display_order: valor.orden,
            is_active: valor.activo
        )
        let bodyData = try? JSONEncoder().encode(dto)
        let _ : MorphologicalValueDTO = try await apiClient.request(endpoint: "/morfologia", method: "POST", body: bodyData)
    }
    
    func actualizar(_ valor: ValorMorfologico) async throws {
        let dto = ToggleStatusDTO(is_active: valor.activo)
        let bodyData = try? JSONEncoder().encode(dto)
        let _ : MorphologicalValueDTO = try await apiClient.request(endpoint: "/morfologia/\(valor.codigo)/estado", method: "PATCH", body: bodyData)
    }
    
    func eliminar(codigo: String) async throws {
        let dto = ToggleStatusDTO(is_active: false)
        let bodyData = try? JSONEncoder().encode(dto)
        let _ : MorphologicalValueDTO = try await apiClient.request(endpoint: "/morfologia/\(codigo)/estado", method: "PATCH", body: bodyData)
    }
}
