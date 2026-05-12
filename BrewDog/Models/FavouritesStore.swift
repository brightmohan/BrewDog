import Foundation
import Observation

@Observable
class FavouritesStore {
    private(set) var favouriteBeers: [Beer] = []

    private var favouriteIDs: Set<Int> = []
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let ids = defaults.array(forKey: "favouriteIDs") as? [Int] ?? []
        favouriteIDs = Set(ids)
        if let data = defaults.data(forKey: "favouriteBeers"),
           let beers = try? JSONDecoder().decode([Beer].self, from: data) {
            favouriteBeers = beers
        }
    }

    func isFavourite(_ beer: Beer) -> Bool {
        favouriteIDs.contains(beer.id)
    }

    func toggle(_ beer: Beer) {
        if favouriteIDs.contains(beer.id) {
            favouriteIDs.remove(beer.id)
            favouriteBeers.removeAll { $0.id == beer.id }
        } else {
            favouriteIDs.insert(beer.id)
            favouriteBeers.append(beer)
        }
        persist()
    }

    private func persist() {
        defaults.set(Array(favouriteIDs), forKey: "favouriteIDs")
        if let data = try? JSONEncoder().encode(favouriteBeers) {
            defaults.set(data, forKey: "favouriteBeers")
        }
    }
}
