import Foundation

@Observable
class BeerListViewModel {
    var beers: [Beer] = []
    var isLoading = false
    var errorMessage: String?

    private let baseURL = "https://punkapi-alxiw.amvera.io/v3/beers"

    func fetchBeers(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)?page=\(page)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            beers = try JSONDecoder().decode([Beer].self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
