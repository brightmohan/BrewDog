import Foundation

@Observable
class BeerListViewModel {
    var beers: [Beer] = []
    var isLoading = false
    var errorMessage: String?

    private let baseURL = "https://punkapi-alxiw.amvera.io/v3/beers"

    func fetchRandomBeer() async -> Beer? {
        guard let url = URL(string: "\(baseURL)/random") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(Beer.self, from: data)
        } catch {
            return nil
        }
    }

    func fetchBeers(page: Int = 1, name: String = "") async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var components = URLComponents(string: baseURL)!
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        if !name.isEmpty {
            queryItems.append(URLQueryItem(name: "beer_name", value: name))
        }
        components.queryItems = queryItems

        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            beers = try JSONDecoder().decode([Beer].self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
