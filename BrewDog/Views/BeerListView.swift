import SwiftUI

struct BeerListView: View {
    enum ViewMode { case list, grid }
    enum SortOrder { case nameAsc, abvDesc }

    @State private var viewModel = BeerListViewModel()
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    @State private var sortOrder: SortOrder = .nameAsc

    private var sortedBeers: [Beer] {
        switch sortOrder {
        case .nameAsc:  return viewModel.beers.sorted { $0.name < $1.name }
        case .abvDesc:  return viewModel.beers.sorted { ($0.abv ?? 0) > ($1.abv ?? 0) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionHeader
                content
            }
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search for beers or food pairings")
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

    private var sectionHeader: some View {
        HStack {
            Text("Beer").font(.title2).bold()
            Spacer()
            Menu {
                Picker("Layout", selection: $viewMode) {
                    Label("Grid", systemImage: "square.grid.2x2").tag(ViewMode.grid)
                    Label("List", systemImage: "list.bullet").tag(ViewMode.list)
                }
                Menu {
                    Picker("Sort by", selection: $sortOrder) {
                        Text("Name").tag(SortOrder.nameAsc)
                        Text("ABV").tag(SortOrder.abvDesc)
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }                
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading beers...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            Text("Error: \(error)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewMode == .list {
            List(sortedBeers) { beer in
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
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(sortedBeers) { beer in
                        NavigationLink(destination: BeerDetailView(beer: beer)) {
                            VStack(spacing: 8) {
                                BeerImageView(url: beer.imageURL, height: 120)
                                Text(beer.name)
                                    .font(.caption)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.primary)
                            }
                            .padding(8)
                            .background(Color.brewCard)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: Color.brewShadow.opacity(0.2), radius: 6, x: 0, y: 2)
                        }
                    }
                }
                .padding()
                .background(Color.brewBackground)
            }
            .background(Color.brewBackground)
        }
    }
}

#Preview {
    BeerListView()
}
