import Testing
import Foundation
@testable import BrewDog

@MainActor
@Suite("FoodProduct Tests")
struct FoodProductTests {

    // MARK: - Helpers

    func decode<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        let data = jsonString.data(using: .utf8)!
        return try JSONDecoder().decode(type, from: data)
    }

    // MARK: - FoodProduct

    @Test("Product name and image URL decode from snake_case keys")
    func foodProductDecodesFromJSON() throws {
        let json = """
        {
            "product_name": "Granola",
            "image_url": "https://example.com/granola.jpg",
            "nutriments": null
        }
        """

        let product = try decode(FoodProduct.self, from: json)

        #expect(product.productName == "Granola")
        #expect(product.imageURL == URL(string: "https://example.com/granola.jpg"))
    }

    @Test("Optional fields are nil when missing from JSON")
    func foodProductHandlesNilFields() throws {
        let json = """
        {
            "product_name": null,
            "image_url": null,
            "nutriments": null
        }
        """

        let product = try decode(FoodProduct.self, from: json)

        #expect(product.productName == nil)
        #expect(product.imageURL == nil)
        #expect(product.nutriments == nil)
    }

    // MARK: - Nutriments

    @Test("Nutriment values decode from snake_case keys")
    func nutrimentsDecodeCorrectly() throws {
        let json = """
        {
            "product_name": "Oat Bar",
            "image_url": null,
            "nutriments": {
                "energy-kcal_100g": 420.0,
                "fat_100g": 12.5,
                "carbohydrates_100g": 60.0,
                "proteins_100g": 8.3
            }
        }
        """

        let product = try decode(FoodProduct.self, from: json)
        let nutriments = try #require(product.nutriments)

        #expect(nutriments.calories == 420.0)
        #expect(nutriments.fat == 12.5)
        #expect(nutriments.carbohydrates == 60.0)
        #expect(nutriments.proteins == 8.3)
    }

    // MARK: - FoodSearchResponse

    @Test("FoodSearchResponse decodes array of products")
    func foodSearchResponseDecodesProducts() throws {
        let json = """
        {
            "products": [
                { "product_name": "Granola", "image_url": null, "nutriments": null },
                { "product_name": "Oat Bar", "image_url": null, "nutriments": null }
            ]
        }
        """

        let response = try decode(FoodSearchResponse.self, from: json)

        #expect(response.products.count == 2)
        #expect(response.products[0].productName == "Granola")
        #expect(response.products[1].productName == "Oat Bar")
    }
}
