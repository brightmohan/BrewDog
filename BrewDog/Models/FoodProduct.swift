import Foundation

struct FoodSearchResponse: Decodable {
    let products: [FoodProduct]
}

struct FoodProduct: Decodable, Identifiable {
    let id = UUID()
    let productName: String?
    let imageURL: URL?
    let nutriments: Nutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case imageURL = "image_url"
        case nutriments
    }
}

struct Nutriments: Decodable {
    let calories: Double?
    let fat: Double?
    let carbohydrates: Double?
    let proteins: Double?

    enum CodingKeys: String, CodingKey {
        case calories = "energy-kcal_100g"
        case fat = "fat_100g"
        case carbohydrates = "carbohydrates_100g"
        case proteins = "proteins_100g"
    }
}
