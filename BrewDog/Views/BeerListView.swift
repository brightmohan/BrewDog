import SwiftUI

struct BeerListView: View {
    @State private var viewModel = BeerListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading beers...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                } else {
                    List(viewModel.beers) { beer in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(beer.name).font(.headline)
                            Text(beer.tagline).font(.subheadline).foregroundStyle(.secondary)
                            Text("First brewed: \(beer.firstBrewed)")
                            Text("ABV: \(beer.abv.map { String($0) } ?? "N/A")%")
                            Text(beer.description).font(.caption).lineLimit(3)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Beers")
            .task {
                await viewModel.fetchBeers()
            }
        }
    }
}

#Preview {
    BeerListView()
}
