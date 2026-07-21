import Foundation

/// Persistencia simple de borradores en UserDefaults (JSON).
enum DraftStorage {

    private static let key = "registrador.drafts"

    static func loadAll() -> [EspecieDraft] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let drafts = try? JSONDecoder().decode([EspecieDraft].self, from: data)
        else { return [] }
        return drafts.sorted { $0.fechaActualizacion > $1.fechaActualizacion }
    }

    static func upsert(_ draft: EspecieDraft) {
        var all = loadAll()
        if let idx = all.firstIndex(where: { $0.id == draft.id }) {
            all[idx] = draft
        } else {
            all.append(draft)
        }
        save(all)
    }

    static func delete(id: String) {
        var all = loadAll()
        all.removeAll { $0.id == id }
        save(all)
    }

    static func get(id: String) -> EspecieDraft? {
        loadAll().first { $0.id == id }
    }

    private static func save(_ drafts: [EspecieDraft]) {
        if let data = try? JSONEncoder().encode(drafts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
