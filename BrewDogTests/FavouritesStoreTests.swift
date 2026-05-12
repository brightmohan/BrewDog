import XCTest
@testable import BrewDog

@MainActor
final class FavouritesStoreTests: XCTestCase {

    var store: FavouritesStore!
    var testDefaults: UserDefaults!

    let suiteName = "FavouritesStoreTests"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        store = FavouritesStore(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        store = nil
        super.tearDown()
    }

    // MARK: - Helpers

    func makeBeer(id: Int, name: String = "Test Beer") -> Beer {
        Beer(
            id: id,
            name: name,
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
    }

    // MARK: - isFavourite

    func testIsFavouriteReturnsFalseInitially() {
        let beer = makeBeer(id: 1)
        XCTAssertFalse(store.isFavourite(beer))
    }

    // MARK: - toggle

    func testToggleAddsBeerToFavourites() {
        let beer = makeBeer(id: 1)
        store.toggle(beer)
        XCTAssertTrue(store.isFavourite(beer))
    }

    func testToggleRemovesBeerFromFavourites() {
        let beer = makeBeer(id: 1)
        store.toggle(beer)
        store.toggle(beer)
        XCTAssertFalse(store.isFavourite(beer))
    }

    func testToggleUpdatesFavouriteBeersArray() {
        let beer = makeBeer(id: 1)

        store.toggle(beer)
        XCTAssertEqual(store.favouriteBeers.count, 1)
        XCTAssertEqual(store.favouriteBeers.first?.id, 1)

        store.toggle(beer)
        XCTAssertTrue(store.favouriteBeers.isEmpty)
    }

    func testToggleMultipleBeers() {
        let beer1 = makeBeer(id: 1, name: "Pale Ale")
        let beer2 = makeBeer(id: 2, name: "Stout")

        store.toggle(beer1)
        store.toggle(beer2)

        XCTAssertEqual(store.favouriteBeers.count, 2)
        XCTAssertTrue(store.isFavourite(beer1))
        XCTAssertTrue(store.isFavourite(beer2))
    }

    // MARK: - Persistence

    func testPersistsToUserDefaults() {
        let beer = makeBeer(id: 42)
        store.toggle(beer)

        let savedIDs = testDefaults.array(forKey: "favouriteIDs") as? [Int]
        XCTAssertEqual(savedIDs, [42])

        let savedData = testDefaults.data(forKey: "favouriteBeers")
        XCTAssertNotNil(savedData)
    }

    func testLoadsFromUserDefaults() {
        let beer = makeBeer(id: 42, name: "Punk IPA")
        store.toggle(beer)

        // Create a fresh store from the same defaults — simulates app relaunch
        let freshStore = FavouritesStore(defaults: testDefaults)
        XCTAssertTrue(freshStore.isFavourite(beer))
        XCTAssertEqual(freshStore.favouriteBeers.first?.name, "Punk IPA")
    }
}
