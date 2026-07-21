import SwiftUI

/// C-12: configuración de la app (notificaciones, tema, idioma, caché, acerca de).
struct ConfiguracionView: View {

    @Environment(AppPreferences.self) private var prefs
    @Environment(ConnectivityStore.self) private var conectividad
    @Environment(\.dismiss) private var dismiss

    @State private var mostrandoConfirmacionCache = false
    @State private var mostrandoAcercaDe = false
    @State private var toast: ToastInfo?

    var body: some View {
        @Bindable var prefs = prefs

        Form {
            Section("Notificaciones") {
                Toggle("Recibir notificaciones", isOn: $prefs.notificacionesActivas)
                    .tint(Color.navigationSelection)
                Text("Te avisamos cuando cambie el estado de tus registros o tu cuenta.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Apariencia") {
                Picker("Tema", selection: $prefs.tema) {
                    ForEach(AppPreferences.Tema.allCases) { t in
                        Text(t.label).tag(t)
                    }
                }
            }

            Section("Idioma") {
                Picker("Idioma", selection: $prefs.idioma) {
                    ForEach(AppPreferences.Idioma.allCases) { l in
                        Text(l.label).tag(l)
                    }
                }
                Text("La traducción completa al inglés llegará en una próxima versión.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Datos") {
                Button(role: .destructive) {
                    mostrandoConfirmacionCache = true
                } label: {
                    Label("Limpiar caché", systemImage: "trash")
                }
            }

            #if DEBUG
            Section("Simulación de red") {
                Toggle("Conexión a internet", isOn: Binding(
                    get: { conectividad.online },
                    set: { _ in conectividad.toggle() }
                ))
                .tint(Color.navigationSelection)
                if !conectividad.online {
                    Text("Las acciones quedarán en cola y se enviarán al volver la conexión.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            #endif

            Section {
                Button {
                    mostrandoAcercaDe = true
                } label: {
                    HStack {
                        Label("Acerca de FlorAmaz", systemImage: "info.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .foregroundStyle(Color.primary)
            }
        }
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.large)
        .alert("¿Limpiar caché?", isPresented: $mostrandoConfirmacionCache) {
            Button("Cancelar", role: .cancel) {}
            Button("Limpiar", role: .destructive) {
                prefs.limpiarCache()
                toast = ToastInfo(kind: .exito, message: "Caché limpia.")
            }
        } message: {
            Text("Se borrarán borradores y favoritos guardados en este dispositivo.")
        }
        .sheet(isPresented: $mostrandoAcercaDe) {
            AcercaDeView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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

    private struct ToastInfo: Identifiable {
        let id = UUID()
        let kind: AppToastKind
        let message: String
    }
}

private struct AcercaDeView: View {
    var body: some View {
        VStack(spacing: 22) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 6)

            Image("logo_floramaz")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)

            Text("FlorAmaz")
                .font(.title2.weight(.bold))

            Text("Beta 1")
                .foregroundStyle(.secondary)

            Text("Catálogo digital de la flora amazónica del Perú. Diseñado para registradores de campo, validadores científicos y consultores académicos.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 8) {
                Text("Hecho con cariño desde Iquitos · 2026")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                VStack(spacing: 3) {
                    Text("Celeste Alva")
                    Text("Danny Ordoñez")
                    Text("Jeysson Cobeñas")
                    Text("Lucas Reategui")
                    Text("Jhor Grandez")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }
}
