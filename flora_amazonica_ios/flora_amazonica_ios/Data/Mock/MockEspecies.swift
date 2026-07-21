import Foundation

/// 17 especies reales de la flora amazónica de Iquitos, Loreto.
/// Coordenadas dispersas alrededor de Iquitos (-3.74°, -73.25°).
enum MockEspecies {

    static let especies: [Especie] = makeAll()

    // MARK: - Construcción

    private static func makeAll() -> [Especie] {
        [
            // ─── Árboles ───
            make(
                id: "e-001", sci: "Cedrela odorata", autor: "L.",
                familia: "Meliaceae", local: "Cedro",
                habito: .arbol,
                descripcion: "Árbol caducifolio de madera fragante muy valorada. Crece en bosques no inundables de la Amazonía baja. Especie en peligro por explotación maderera.",
                caracteres: [
                    "hoja": "Compuesta paripinnada, 30–50 cm",
                    "flor": "Pequeña, blanco-verdosa, en panículas terminales",
                    "fruto": "Cápsula leñosa dehiscente, 4–5 cm",
                    "corteza": "Fisurada longitudinalmente, gris parda"
                ],
                altura: 32, cap: 195,
                lat: -3.74, long: -73.21, habitat: "Bosque de tierra firme",
                estado: .publicado, codigo: "FLORA-2026-001", regId: "u-001", diasAtras: 60
            ),
            make(
                id: "e-002", sci: "Swietenia macrophylla", autor: "King",
                familia: "Meliaceae", local: "Caoba",
                habito: .arbol,
                descripcion: "Árbol emergente de gran porte, una de las maderas más cotizadas del trópico. Distribución natural muy reducida por sobreexplotación.",
                caracteres: [
                    "hoja": "Compuesta paripinnada, 20–45 cm",
                    "flor": "Blanca, pequeña, en panículas axilares",
                    "fruto": "Cápsula leñosa ovoide, 12–18 cm",
                    "corteza": "Pardo-rojiza, agrietada en placas"
                ],
                altura: 42, cap: 245,
                lat: -3.78, long: -73.33, habitat: "Bosque de tierra firme",
                estado: .validado, codigo: "FLORA-2026-002", regId: "u-001", diasAtras: 45
            ),
            make(
                id: "e-003", sci: "Ceiba pentandra", autor: "(L.) Gaertn.",
                familia: "Malvaceae", local: "Lupuna",
                habito: .arbol,
                descripcion: "Árbol emergente que sobresale del dosel, puede superar los 60 m de altura. Tronco cilíndrico con grandes aletones tabulares.",
                caracteres: [
                    "hoja": "Digitada, 5–9 folíolos lanceolados",
                    "flor": "Blanco-amarillenta, pentámera",
                    "fruto": "Cápsula con fibra algodonosa (kapok)",
                    "corteza": "Lisa, gris, con aguijones cónicos en juveniles"
                ],
                altura: 55, cap: 320,
                lat: -3.71, long: -73.27, altitud: 105, habitat: "Bosque de tierra firme",
                estado: .publicado, codigo: "FLORA-2026-003", regId: "u-002", diasAtras: 30
            ),
            make(
                id: "e-004", sci: "Calycophyllum spruceanum", autor: "(Benth.) Hook. f. ex K. Schum.",
                familia: "Rubiaceae", local: "Capirona",
                habito: .arbol,
                descripcion: "Árbol pionero de corteza lisa y brillante que se exfolia anualmente. Madera dura usada en construcción rural.",
                caracteres: [
                    "hoja": "Simple, opuesta, elíptica, 8–15 cm",
                    "flor": "Blanca, fragante, en panículas terminales",
                    "fruto": "Cápsula pequeña, dehiscente",
                    "corteza": "Lisa, verde-amarillenta, exfoliante"
                ],
                altura: 28, cap: 160,
                lat: -3.69, long: -73.20, altitud: 102, habitat: "Bosque inundable de várzea",
                estado: .enRevision, codigo: "FLORA-2026-004", regId: "u-002", diasAtras: 12
            ),
            make(
                id: "e-005", sci: "Bertholletia excelsa", autor: "Bonpl.",
                familia: "Lecythidaceae", local: "Castaña",
                habito: .arbol,
                descripcion: "Árbol emergente de gran longevidad. Produce el fruto conocido como castaña amazónica o nuez de Brasil, eje económico no maderable.",
                caracteres: [
                    "hoja": "Simple, alterna, oblonga, 25–35 cm",
                    "flor": "Crema, en racimos terminales",
                    "fruto": "Pixidio leñoso esférico de 10–15 cm",
                    "corteza": "Pardo grisácea, agrietada longitudinalmente"
                ],
                altura: 48, cap: 280,
                lat: -3.65, long: -73.40, habitat: "Bosque de tierra firme",
                estado: .observado, codigo: "FLORA-2026-005", regId: "u-001", diasAtras: 20
            ),
            make(
                id: "e-006", sci: "Hura crepitans", autor: "L.",
                familia: "Euphorbiaceae", local: "Catahua",
                habito: .arbol,
                descripcion: "Árbol grande con tronco lleno de aguijones cónicos. Su látex es tóxico. Fruto explosivo que dispersa las semillas a metros de distancia.",
                caracteres: [
                    "hoja": "Simple, alterna, ovada, 10–20 cm",
                    "flor": "Roja, en espigas; planta monoica",
                    "fruto": "Cápsula leñosa achatada, dehiscente explosiva",
                    "corteza": "Gris con aguijones cónicos abundantes"
                ],
                altura: 38, cap: 220,
                lat: -3.80, long: -73.15, habitat: "Bosque inundable",
                estado: .publicado, codigo: "FLORA-2026-006", regId: "u-001", diasAtras: 75
            ),
            make(
                id: "e-007", sci: "Hymenaea courbaril", autor: "L.",
                familia: "Fabaceae", local: "Azúcar huayo",
                habito: .arbol,
                descripcion: "Árbol robusto productor de resina (copal). Fruto en vaina dura con pulpa harinosa comestible de aroma característico.",
                caracteres: [
                    "hoja": "Compuesta bifoliolada, folíolos asimétricos",
                    "flor": "Blanco-rosada, en panículas terminales",
                    "fruto": "Legumbre leñosa indehiscente, 8–15 cm",
                    "corteza": "Gris, lisa a finamente agrietada"
                ],
                altura: 34, cap: 210,
                lat: -3.92, long: -73.35, altitud: 130, habitat: "Bosque de tierra firme",
                estado: .validado, codigo: "FLORA-2026-007", regId: "u-002", diasAtras: 40
            ),
            make(
                id: "e-008", sci: "Dipteryx odorata", autor: "(Aubl.) Willd.",
                familia: "Fabaceae", local: "Shihuahuaco",
                habito: .arbol,
                descripcion: "Árbol de madera densa y muy resistente. Semilla aromática (haba tonka) usada en perfumería. Especie clave por su tamaño y longevidad.",
                caracteres: [
                    "hoja": "Compuesta pinnada, raquis alado",
                    "flor": "Rosa-violácea, en racimos",
                    "fruto": "Drupa con semilla aromática",
                    "corteza": "Pardo rojiza, descascarable en placas"
                ],
                altura: 45, cap: 260,
                lat: -3.62, long: -73.10, habitat: "Bosque de tierra firme",
                estado: .publicado, codigo: "FLORA-2026-008", regId: "u-002", diasAtras: 50
            ),

            // ─── Palmeras ───
            make(
                id: "e-009", sci: "Mauritia flexuosa", autor: "L. f.",
                familia: "Arecaceae", local: "Aguaje",
                habito: .palmera,
                descripcion: "Palmera dioica de grandes aguajales. Su fruto es de enorme importancia económica y cultural en Loreto. Indicador de ecosistemas inundables.",
                caracteres: [
                    "hoja": "Costapalmada, hasta 3 m de diámetro",
                    "flor": "Inflorescencia interfoliar, planta dioica",
                    "fruto": "Drupa elipsoidal con escamas romboidales rojizas",
                    "tallo": "Estipe solitario, anillado, 20–35 m"
                ],
                altura: 28, cap: 145,
                lat: -3.85, long: -73.45, altitud: 95, habitat: "Aguajal inundable",
                estado: .publicado, codigo: "FLORA-2026-009", regId: "u-001", diasAtras: 25
            ),
            make(
                id: "e-010", sci: "Euterpe precatoria", autor: "Mart.",
                familia: "Arecaceae", local: "Huasaí",
                habito: .palmera,
                descripcion: "Palmera de estipe solitario del que se extrae el palmito y el fruto para bebidas. Crece tanto en tierra firme como en zonas inundables.",
                caracteres: [
                    "hoja": "Pinnada, 3–4 m de largo, péndula",
                    "flor": "Inflorescencia interfoliar ramificada",
                    "fruto": "Drupa esférica, morado oscuro al madurar",
                    "tallo": "Estipe delgado, anillado, 15–25 m"
                ],
                altura: 22, cap: 60,
                lat: -3.75, long: -73.30, habitat: "Bosque de tierra firme",
                estado: .validado, codigo: "FLORA-2026-010", regId: "u-002", diasAtras: 35
            ),
            make(
                id: "e-011", sci: "Astrocaryum chambira", autor: "Burret",
                familia: "Arecaceae", local: "Chambira",
                habito: .palmera,
                descripcion: "Palmera espinosa cuyas fibras se usan tradicionalmente para tejer hamacas y mochilas. Importante para comunidades indígenas amazónicas.",
                caracteres: [
                    "hoja": "Pinnada, raquis y vainas con espinas negras",
                    "flor": "Inflorescencia interfoliar",
                    "fruto": "Drupa ovoide, mesocarpio fibroso amarillo",
                    "tallo": "Estipe con anillos espinosos, 10–18 m"
                ],
                altura: 16, cap: 90,
                lat: -3.70, long: -73.18, habitat: "Bosque secundario",
                estado: .enRevision, codigo: "FLORA-2026-011", regId: "u-001", diasAtras: 8
            ),
            make(
                id: "e-012", sci: "Iriartea deltoidea", autor: "Ruiz & Pav.",
                familia: "Arecaceae", local: "Huacrapona",
                habito: .palmera,
                descripcion: "Palmera con un característico abultamiento en el estipe. Sus raíces zancudas sostienen la planta en suelos blandos. Madera muy usada en construcción.",
                caracteres: [
                    "hoja": "Pinnada, folíolos premorsos en forma de delta",
                    "flor": "Inflorescencia infrafoliar",
                    "fruto": "Drupa globosa amarillo-naranja",
                    "tallo": "Estipe con engrosamiento mediano, 20–30 m"
                ],
                altura: 26, cap: 100,
                lat: -3.66, long: -73.25, habitat: "Bosque de tierra firme",
                estado: .publicado, codigo: "FLORA-2026-012", regId: "u-002", diasAtras: 90
            ),

            // ─── Arbustos ───
            make(
                id: "e-013", sci: "Psychotria viridis", autor: "Ruiz & Pav.",
                familia: "Rubiaceae", local: "Chacruna",
                habito: .arbusto,
                descripcion: "Arbusto de sotobosque de la amazonía occidental. Sus hojas contienen DMT y son uno de los dos ingredientes tradicionales del brebaje ayahuasca.",
                caracteres: [
                    "hoja": "Simple, opuesta, elíptica, 10–18 cm",
                    "flor": "Pequeña, blanca, en inflorescencias terminales",
                    "fruto": "Drupa roja al madurar",
                    "tallo": "Ramificado desde la base, hasta 5 m"
                ],
                lat: -3.78, long: -73.22, habitat: "Sotobosque de tierra firme",
                estado: .validado, codigo: "FLORA-2026-013", regId: "u-001", diasAtras: 18
            ),
            make(
                id: "e-014", sci: "Croton lechleri", autor: "Müll. Arg.",
                familia: "Euphorbiaceae", local: "Sangre de grado",
                habito: .arbusto,
                descripcion: "Arbusto o arbolito que exuda un látex rojo intenso al cortarlo. La savia tiene usos medicinales tradicionales bien documentados.",
                caracteres: [
                    "hoja": "Simple, alterna, acorazonada, 10–20 cm",
                    "flor": "Pequeña, blanco-verdosa, en racimos",
                    "fruto": "Cápsula tricoca pequeña",
                    "tallo": "Corteza gris con látex rojo abundante"
                ],
                altura: 9, cap: 35,
                lat: -3.81, long: -73.42, habitat: "Bosque secundario",
                estado: .observado, codigo: "FLORA-2026-014", regId: "u-002", diasAtras: 14
            ),

            // ─── Lianas ───
            make(
                id: "e-015", sci: "Banisteriopsis caapi", autor: "(Spruce ex Griseb.) C. V. Morton",
                familia: "Malpighiaceae", local: "Ayahuasca",
                habito: .liana, tipoVida: .terrestre,
                descripcion: "Liana leñosa de gran longitud que trepa al dosel. Su tallo es el componente base de la bebida ceremonial ayahuasca, de uso tradicional milenario.",
                caracteres: [
                    "hoja": "Simple, opuesta, ovada-elíptica",
                    "flor": "Rosa pálido a blanca, en panículas axilares",
                    "fruto": "Sámara con ala dorsal",
                    "tallo": "Cilíndrico, retorcido, con corteza pardo-grisácea"
                ],
                lat: -3.84, long: -73.28, habitat: "Bosque de tierra firme",
                estado: .publicado, codigo: "FLORA-2026-015", regId: "u-001", diasAtras: 100
            ),
            make(
                id: "e-016", sci: "Uncaria tomentosa", autor: "(Willd. ex Schult.) DC.",
                familia: "Rubiaceae", local: "Uña de gato",
                habito: .liana,
                descripcion: "Liana trepadora con espinas curvadas en forma de garra. Su corteza tiene reconocidos usos medicinales como inmunomodulador.",
                caracteres: [
                    "hoja": "Simple, opuesta, ovada, pubescente",
                    "flor": "Crema, en cabezuelas globosas",
                    "fruto": "Cápsula pequeña con semillas aladas",
                    "tallo": "Con espinas axilares recurvadas tipo garra"
                ],
                lat: -3.73, long: -73.36, habitat: "Bosque secundario",
                estado: .validado, codigo: "FLORA-2026-016", regId: "u-002", diasAtras: 22
            ),

            // ─── Hierbas ───
            make(
                id: "e-017", sci: "Heliconia rostrata", autor: "Ruiz & Pav.",
                familia: "Heliconiaceae", local: "Bijao colgante",
                habito: .hierba,
                descripcion: "Herbácea robusta con inflorescencia péndula de brácteas rojas con borde amarillo. Polinizada por colibríes. Muy ornamental.",
                caracteres: [
                    "hoja": "Simple, oblonga, hasta 1.5 m, dística",
                    "flor": "Inflorescencia péndula con brácteas rojo-amarillas",
                    "fruto": "Drupa azulada",
                    "tallo": "Pseudotallo formado por vainas foliares"
                ],
                lat: -3.76, long: -73.24, habitat: "Borde de bosque, claros húmedos",
                estado: .borrador, codigo: "FLORA-2026-017", regId: "u-002", diasAtras: 2
            )
        ]
    }

    // MARK: - Helpers

    private static func make(
        id: String,
        sci: String,
        autor: String,
        familia: String,
        local: String,
        habito: Habito,
        tipoVida: TipoVida = .terrestre,
        descripcion: String,
        caracteres: [String: String],
        altura: Double? = nil,
        cap: Double? = nil,
        lat: Double,
        long: Double,
        altitud: Double = 110,
        habitat: String,
        estado: EstadoRegistro,
        codigo: String,
        regId: String,
        diasAtras: Int
    ) -> Especie {
        let fechaEnvio = Date().addingTimeInterval(-Double(diasAtras) * 86_400)

        let datos: DatosDasometricos? = {
            guard let altura, let cap else { return nil }
            return DatosDasometricos(
                altura: altura,
                cap: cap,
                diamCopaParalelo: altura * 0.25,
                diamCopaPerpendicular: altura * 0.22,
                alturaInicioCopa: altura * 0.55
            )
        }()

        return Especie(
            id: id,
            nombreCientifico: sci,
            autorNombre: autor,
            familia: familia,
            nombreLocal: local,
            habito: habito,
            tipoVida: tipoVida,
            distribucionPaises: ["Perú", "Brasil", "Ecuador", "Colombia", "Bolivia"],
            descripcion: descripcion,
            caracteres: caracteres,
            datosDasometricos: datos,
            ubicacion: Ubicacion(
                lat: lat, long: long,
                referencia: "Iquitos, Loreto",
                altitud: altitud,
                tipoHabitat: habitat
            ),
            fotos: makeFotos(sci: sci, fecha: fechaEnvio),
            estado: estado,
            codigoSeguimiento: codigo,
            registradorId: regId,
            fechaEnvio: fechaEnvio,
            historialEstados: [
                HistorialEstado(
                    id: "h-\(id)-1",
                    estado: estado,
                    fecha: fechaEnvio,
                    usuarioId: regId,
                    comentario: nil
                )
            ]
        )
    }

    private static func makeFotos(sci: String, fecha: Date) -> [Foto] {
        let tipos: [TipoFoto] = [.plantaCompleta, .hoja, .flor, .fruto, .talloCorteza]
        let slug = sci.replacingOccurrences(of: " ", with: "-").lowercased()
        return tipos.enumerated().map { idx, tipo in
            let seed = "\(slug)-\(tipo.rawValue)"
            let url: URL
            if sci == "Cedrela odorata" && tipo == .plantaCompleta {
                if let localURL = Bundle.main.url(forResource: "cedrela_odorata_plantaCompleta", withExtension: "jpg") {
                    url = localURL
                } else {
                    url = URL(string: "https://picsum.photos/seed/\(seed)/800/800")!
                }
            } else {
                url = URL(string: "https://picsum.photos/seed/\(seed)/800/800")!
            }
            return Foto(
                id: "f-\(sci.replacingOccurrences(of: " ", with: "_"))-\(tipo.rawValue)",
                tipo: tipo,
                url: url,
                autor: "Equipo Flora",
                fecha: fecha.addingTimeInterval(-Double(idx) * 3600)
            )
        }
    }
}
