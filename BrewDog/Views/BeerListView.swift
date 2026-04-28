import SwiftUI

struct BeerListView: View {
    @State private var viewModel = BeerListViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading beers...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                } else {
                    List(viewModel.beers) { beer in
                        NavigationLink(destination: BeerDetailView(beer: beer)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(beer.name).font(.headline)
                                Text(beer.tagline).font(.subheadline).foregroundStyle(.secondary)
                                Text("First brewed: \(beer.firstBrewed)")
                                Text("ABV: \(beer.abv.map { String($0) } ?? "N/A")%")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Beers")
            .searchable(text: $searchText, prompt: "Search beers")
            .onSubmit(of: .search) {
                Task { await viewModel.fetchBeers(name: searchText) }
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    Task { await viewModel.fetchBeers() }
                }
            }
            .task {
                await viewModel.fetchBeers()
            }
        }
    }
}

#Preview {
    BeerListView()
}
