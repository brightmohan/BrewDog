import Foundation

struct Beer: Codable, Identifiable {
    let id: Int
    let name: String
    let tagline: String
    let firstBrewed: String
    let description: String
    let image: String?
    let abv: Float?
    let ibu: Float?
    let ingredients: Ingredients?
    let brewersTips: String?
    let foodPairing: [String]?

    var imageURL: URL? {
        guard let image else { return nil }
        return URL(string: "https://punkapi-alxiw.amvera.io/v3/images/\(image)")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, tagline, description, image, abv, ibu, ingredients
        case firstBrewed = "first_brewed"
        case brewersTips = "brewers_tips"
        case foodPairing = "food_pairing"
    }
}

struct Ingredients: Codable {
    let malt: [Malt]?
    let hops: [Hop]?
    let yeast: String?
}

struct Malt: Codable {
    let name: String
    let amount: Amount
}

struct Hop: Codable {
    let name: String
    let amount: Amount
    let add: String?
    let attribute: String?
}

struct Amount: Codable {
    let value: Float
    let unit: String
}
