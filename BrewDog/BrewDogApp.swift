import SwiftUI

@main
struct BrewDogApp: App {
    @State private var favourites = FavouritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favourites)
        }
    }
}
