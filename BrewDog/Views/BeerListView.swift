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
