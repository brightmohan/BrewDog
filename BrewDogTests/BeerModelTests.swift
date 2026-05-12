import XCTest
@testable import BrewDog

@MainActor
final class BeerModelTests: XCTestCase {
    
    func testImageURLReturnsNilWhenImageIsNil(){
        let beer = Beer(
            id: 1,
            name: "Test Beer",
            tagline: "A test",
            firstBrewed: "01/2020",
            description: "A test beer",
            image: nil,
            abv: 5.0,
            ibu: 40,
            ingredients: nil,
            brewersTips: nil,
            foodPairing: nil
        )
        
        XCTAssertNil(beer.imageURL, "imageURL shoud be nil when image is nil")
    }
    
    func testImageURLReturnsCorrectURLWhenImageExists() {
        
        let beer = Beer(
            id: 1,
            name: "Test Beer",
            tagline: "A test",
            firstBrewed: "01/2020",
            description: "A test beer",
            image: "kc_beer.png",
            abv: 5.0,
            ibu: 40,
            ingredients: nil,
            brewersTips: nil,
            foodPairing: nil
        )
        
        XCTAssertNotNil(beer.imageURL, "imageURL should not be nil when image exists")
        XCTAssertTrue(beer.imageURL!.absoluteString.contains("kc_beer.png"), "imageURL should contain the image filename")
    }

    // MARK: - JSON Decoding (CodingKeys)

    func testBeerDecodesFromJSON() throws {
        let json = """
        {
            "id": 42,
            "name": "Punk IPA",
            "tagline": "Post Modern Classic",
            "first_brewed": "04/2007",
            "description": "A bold IPA.",
            "image": "punk_ipa.png",
            "abv": 5.6,
            "ibu": 41.5,
            "ingredients": null,
            "brewers_tips": "Dry hop generously.",
            "food_pairing": ["Spicy curry", "Blue cheese"]
        }
        """.data(using: .utf8)!

        let beer = try JSONDecoder().decode(Beer.self, from: json)

        XCTAssertEqual(beer.id, 42)
        XCTAssertEqual(beer.name, "Punk IPA")
        XCTAssertEqual(beer.firstBrewed, "04/2007")
        XCTAssertEqual(beer.brewersTips, "Dry hop generously.")
        XCTAssertEqual(beer.foodPairing, ["Spicy curry", "Blue cheese"])
        XCTAssertEqual(beer.abv!, 5.6, accuracy: 0.01)
        XCTAssertEqual(beer.ibu!, 41.5, accuracy: 0.01)
    }

    func testBeerWithNilOptionals() throws {
        let json = """
        {
            "id": 1,
            "name": "Mystery Beer",
            "tagline": "Unknown",
            "first_brewed": "01/2000",
            "description": "No details.",
            "image": null,
            "abv": null,
            "ibu": null,
            "ingredients": null,
            "brewers_tips": null,
            "food_pairing": null
        }
        """.data(using: .utf8)!

        let beer = try JSONDecoder().decode(Beer.self, from: json)

        XCTAssertNil(beer.image)
        XCTAssertNil(beer.abv)
        XCTAssertNil(beer.ibu)
        XCTAssertNil(beer.ingredients)
        XCTAssertNil(beer.brewersTips)
        XCTAssertNil(beer.foodPairing)
        XCTAssertNil(beer.imageURL)
    }

    // MARK: - Ingredients Decoding

    func testIngredientsDecoding() throws {
        let json = """
        {
            "id": 10,
            "name": "Hop Head",
            "tagline": "Hoppy",
            "first_brewed": "06/2015",
            "description": "Very hoppy.",
            "image": null,
            "abv": 6.0,
            "ibu": 60.0,
            "ingredients": {
                "malt": [{ "name": "Pale Malt", "amount": { "value": 5.0, "unit": "kilograms" } }],
                "hops": [{ "name": "Simcoe", "amount": { "value": 25.0, "unit": "grams" }, "add": "end", "attribute": "flavour" }],
                "yeast": "Wyeast 1056"
            },
            "brewers_tips": null,
            "food_pairing": null
        }
        """.data(using: .utf8)!

        let beer = try JSONDecoder().decode(Beer.self, from: json)

        XCTAssertEqual(beer.ingredients?.yeast, "Wyeast 1056")

        let malt = try XCTUnwrap(beer.ingredients?.malt?.first)
        XCTAssertEqual(malt.name, "Pale Malt")
        XCTAssertEqual(malt.amount.value, 5.0, accuracy: 0.01)
        XCTAssertEqual(malt.amount.unit, "kilograms")

        let hop = try XCTUnwrap(beer.ingredients?.hops?.first)
        XCTAssertEqual(hop.name, "Simcoe")
        XCTAssertEqual(hop.add, "end")
        XCTAssertEqual(hop.attribute, "flavour")
        XCTAssertEqual(hop.amount.value, 25.0, accuracy: 0.01)
    }

    // MARK: - Food Pairing

    func testFoodPairingDecodes() throws {
        let json = """
        {
            "id": 5,
            "name": "Stout",
            "tagline": "Dark",
            "first_brewed": "11/2010",
            "description": "Rich stout.",
            "image": null,
            "abv": 7.2,
            "ibu": null,
            "ingredients": null,
            "brewers_tips": null,
            "food_pairing": ["Chocolate cake", "Oysters", "Smoked salmon"]
        }
        """.data(using: .utf8)!

        let beer = try JSONDecoder().decode(Beer.self, from: json)

        XCTAssertEqual(beer.foodPairing?.count, 3)
        XCTAssertEqual(beer.foodPairing?[0], "Chocolate cake")
        XCTAssertEqual(beer.foodPairing?[1], "Oysters")
        XCTAssertEqual(beer.foodPairing?[2], "Smoked salmon")
    }
}
