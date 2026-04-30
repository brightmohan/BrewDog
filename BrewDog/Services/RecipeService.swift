import Foundation

struct RecipeService {
    private static let baseURL = "https://world.openfoodfacts.org/cgi/search.pl"

    static func search(query: String) async throws -> FoodProduct? {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "1"),
            URLQueryItem(name: "fields", value: "product_name,image_url,nutriments")
        ]
        guard let url = components.url else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FoodSearchResponse.self, from: data)
        return response.products.first
    }
}
