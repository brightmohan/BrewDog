import Testing
import Foundation
@testable import BrewDog

@MainActor
@Suite("BeerListViewModel Tests", .serialized)
struct BeerListViewModelTests {

    // MARK: - Helpers

    /// Creates a URLSession wired up to MockURLProtocol so no real network calls are made.
    func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    func makeResponse(for url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    func beerJSON(id: Int = 1, name: String = "Punk IPA") -> String {
        """
        {
            "id": \(id),
            "name": "\(name)",
            "tagline": "Post Modern Classic",
            "first_brewed": "04/2007",
            "description": "A bold IPA.",
            "image": null,
            "abv": 5.6,
            "ibu": 41.5,
            "ingredients": null,
            "brewers_tips": null,
            "food_pairing": null
        }
        """
    }

    // MARK: - fetchBeers

    @Test("fetchBeers populates beers array on success")
    func fetchBeersPopulatesBeers() async throws {
        let json = "[\(beerJSON())]".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (self.makeResponse(for: request.url!), json)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        await viewModel.fetchBeers()

        #expect(viewModel.beers.count == 1)
        #expect(viewModel.beers.first?.name == "Punk IPA")
        #expect(viewModel.errorMessage == nil)
    }

    @Test("fetchBeers sets errorMessage on failure")
    func fetchBeersSetsErrorOnFailure() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        await viewModel.fetchBeers()

        #expect(viewModel.beers.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("fetchBeers includes beer_name query param when name provided")
    func fetchBeersWithNameIncludesQueryParam() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return (self.makeResponse(for: request.url!), "[]".data(using: .utf8)!)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        await viewModel.fetchBeers(name: "punk")

        let components = try #require(capturedURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        let beerNameParam = components.queryItems?.first { $0.name == "beer_name" }
        #expect(beerNameParam?.value == "punk")
    }

    @Test("fetchBeers excludes beer_name query param when name is empty")
    func fetchBeersWithoutNameExcludesQueryParam() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return (self.makeResponse(for: request.url!), "[]".data(using: .utf8)!)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        await viewModel.fetchBeers()

        let components = try #require(capturedURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        let beerNameParam = components.queryItems?.first { $0.name == "beer_name" }
        #expect(beerNameParam == nil)
    }

    @Test("fetchBeers isLoading is false after fetch completes")
    func fetchBeersIsLoadingFalseAfterFetch() async {
        MockURLProtocol.requestHandler = { request in
            (self.makeResponse(for: request.url!), "[]".data(using: .utf8)!)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        await viewModel.fetchBeers()

        #expect(viewModel.isLoading == false)
    }

    // MARK: - fetchRandomBeer

    @Test("fetchRandomBeer returns decoded beer on success")
    func fetchRandomBeerReturnsDecodedBeer() async throws {
        let json = beerJSON(id: 99, name: "Mystery Brew").data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (self.makeResponse(for: request.url!), json)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        let beer = await viewModel.fetchRandomBeer()

        #expect(beer?.id == 99)
        #expect(beer?.name == "Mystery Brew")
    }

    @Test("fetchRandomBeer returns nil on failure")
    func fetchRandomBeerReturnsNilOnFailure() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        let viewModel = BeerListViewModel(session: makeMockSession())
        let beer = await viewModel.fetchRandomBeer()

        #expect(beer == nil)
    }
}
