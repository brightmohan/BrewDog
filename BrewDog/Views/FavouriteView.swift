import SwiftUI

struct FavouriteView: View {
    @Environment(FavouritesStore.self) private var favourites

    var body: some View {
        NavigationStack {
            Group {
                if favourites.favouriteBeers.isEmpty {
                    ContentUnavailableView(
                        "No favourites yet",
                        systemImage: "heart",
                        description: Text("Tap the heart on any beer to save it here.")
                    )
                } else {
                    List(favourites.favouriteBeers) { beer in
                        NavigationLink(destination: BeerDetailView(beer: beer)) {
                            HStack(spacing: 12) {
                                BeerImageView(url: beer.imageURL, height: 60)
                                    .frame(width: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(beer.name).font(.headline)
                                    Text(beer.tagline).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.brewCard)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.brewBackground)
                }
            }
            .navigationTitle("Favourites")
        }
    }
}

#Preview {
    FavouriteView()
        .environment(FavouritesStore())
}
