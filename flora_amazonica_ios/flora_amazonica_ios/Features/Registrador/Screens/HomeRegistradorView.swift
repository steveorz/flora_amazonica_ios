import SwiftUI

/// R-01: home del registrador con saludo, tarjeta de crear, contadores y últimos registros.
struct HomeRegistradorView: View {

    @Environment(SessionStore.self) private var session
    @Environment(EspecieService.self) private var especies

    @State private var presentingNuevo = false
    @State private var drafts: [EspecieDraft] = []

    private var misRegistros: [Especie] {
        guard let uid = session.usuario?.id else { return [] }
        return especies.registrosDe(usuarioId: uid)
    }

    private var conteo: [EstadoRegistro: Int] {
        Dictionary(grouping: misRegistros, by: \.estado).mapValues(\.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                saludo
                crearCard
                resumen
                ultimos
            }
            .padding()
        }
        .navigationTitle("Inicio")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .navigationDestination(for: Especie.self) { e in
            DetalleRegistroView(especie: e)
        }
        .task {
            if especies.especies.isEmpty {
                await especies.cargar()
            }
            drafts = DraftStorage.loadAll()
        }
        .refreshable {
            await especies.cargar()
            drafts = DraftStorage.loadAll()
        }
        .fullScreenCover(isPresented: $presentingNuevo, onDismiss: {
            drafts = DraftStorage.loadAll()
        }) {
            NuevoRegistroView()
        }
    }

    private var saludo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hola, \(session.usuario?.nombres ?? "Investigador")")
                .font(.title2.weight(.semibold))
            Text("Documenta una nueva especie del bosque.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var crearCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer(minLength: 0)
            // Todo el bloque va abajo, sobre el scrim oscuro: botón de vidrio
            // justo encima del título.
            Button {
                presentingNuevo = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                    Text("Comenzar")
                }
                .font(.subheadline.weight(.semibold))
                // Negro fijo: el label por defecto de Liquid Glass en modo claro.
                .foregroundStyle(.black)
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
            }
            .buttonStyle(.glass)
            .padding(.bottom, 8)
            Text("Crear nuevo registro")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text("Wizard de 7 pasos con guardado automático.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 230)
        .background {
            ZStack {
                Color.heading
                Image("fondo_crear_registro")
                    .resizable()
                    .scaledToFill()
                // Scrim para que el texto y el vidrio se lean sobre la foto.
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var resumen: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resumen").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statLink("En revisión", value: conteo[.enRevision] ?? 0, estado: .enRevision)
                statLink("Observados",  value: conteo[.observado] ?? 0,  estado: .observado)
                statLink("Validados",   value: conteo[.validado] ?? 0,   estado: .validado)
                NavigationLink {
                    BorradoresView()
                } label: {
                    stat("Borradores", value: drafts.count, color: .gray)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func statLink(_ title: String, value: Int, estado: EstadoRegistro) -> some View {
        NavigationLink {
            MisRegistrosView(filtroInicial: estado)
        } label: {
            stat(title, value: value, color: estado.color)
        }
        .buttonStyle(.plain)
    }

    private func stat(_ title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    private var ultimos: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tus últimos registros").font(.headline)
            if misRegistros.isEmpty {
                Text("Aún no tienes registros.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 18)
            } else {
                VStack(spacing: 0) {
                    ForEach(misRegistros.prefix(4)) { e in
                        NavigationLink(value: e) {
                            SpeciesCard(especie: e, variant: .lista)
                        }
                        .buttonStyle(.plain)
                        if e.id != misRegistros.prefix(4).last?.id { Divider() }
                    }
                }
            }
        }
    }
}
