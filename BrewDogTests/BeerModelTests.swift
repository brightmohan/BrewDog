import XCTest
@testable import BrewDog

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
}
