struct Beer: Codable, Identifiable {
    let id: Int
    let name: String
    let tagline: String
    let firstBrewed: String
    let description: String
    let image: String?
    let abv: Float?
    
    enum CodingKeys: String, CodingKey{
        case id, name, tagline, description, image, abv
        case firstBrewed = "first_brewed"
    }
    
}

