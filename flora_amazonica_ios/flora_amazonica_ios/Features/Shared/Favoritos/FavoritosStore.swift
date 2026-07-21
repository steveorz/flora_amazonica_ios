import Foundation
import Observation

@MainActor
@Observable
final class FavoritosStore {

    var ids: Set<String>

    init() {
        self.ids = FavoritosStorage.load()
    }

    func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        FavoritosStorage.save(ids)
    }

    func isFavorite(_ id: String) -> Bool {
        ids.contains(id)
    }
}
