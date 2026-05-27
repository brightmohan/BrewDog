# BrewDog 🍺

A SwiftUI app built to explore real-world iOS patterns using the [Punk API](https://punkapi-alxiw.amvera.io/v3/beers) — a catalogue of craft beers. A second live API ([OpenFoodFacts](https://world.openfoodfacts.org)) is called when you tap a food pairing suggestion.

## What it does

- Browse a paginated list of craft beers (list view or grid view)
- Search beers by name in real-time
- "Spin the bottle" — fetches a random beer with a dice animation
- View full beer details: ABV, IBU, ingredients (malt, hops, yeast), brewer's tips
- Tap any food pairing suggestion → fetches nutrition info from OpenFoodFacts
- Heart any beer → saved to Favourites tab, persisted across app launches

## Screenshots

| Home (List) | Home (Grid) | Beer Detail | Food Pairing | Favourites |
|-------------|-------------|-------------|--------------|------------|
| Beer list with search | 2-column grid | Ingredients, tips, pairings | Nutrition card from OpenFoodFacts | Persisted favourites |

## Architecture

```
MVVM + SwiftUI + Swift Observation framework

BrewDogApp
└── ContentView (TabView — Home + Favourites)
    ├── BeerListView         ← @Observable ViewModel drives all state
    │   └── BeerDetailView   ← reads Beer model, reads FavouritesStore from environment
    │       └── RecipeSheetView  ← calls OpenFoodFacts API for food pairing nutrition
    └── FavouriteView        ← reads FavouritesStore from environment
```

```
BrewDog/
├── BrewDogApp.swift          # App entry point — injects FavouritesStore into environment
├── ContentView.swift         # TabView: Home + Favourites tabs
├── Models/
│   ├── Beer.swift            # Codable model — CodingKeys for snake_case API
│   ├── FavouritesStore.swift # @Observable store — persists to UserDefaults
│   └── FoodProduct.swift     # Decodable — OpenFoodFacts API response
├── Services/
│   └── RecipeService.swift   # Static async function — URLComponents + URLSession
├── ViewModels/
│   └── BeerListViewModel.swift  # @Observable — async/await network calls
└── Views/
    ├── BeerListView.swift    # List/grid toggle, search, sort, spin the bottle
    ├── BeerDetailView.swift  # Full beer detail — decomposed into private subviews
    ├── BeerImageView.swift   # AsyncImage with loading/failure states
    ├── FavouriteView.swift   # Reads from FavouritesStore environment object
    └── RecipeSheetView.swift # Bottom sheet — OpenFoodFacts nutrition lookup
```

## iOS concepts demonstrated

### Swift Observation (`@Observable`)
The modern replacement for `ObservableObject` + `@Published` (introduced iOS 17):
```swift
@Observable
class BeerListViewModel {
    var beers: [Beer] = []      // SwiftUI automatically tracks this
    var isLoading = false       // no @Published needed
}
```
`@Observable` uses macro-based property observation — the compiler instruments each stored property. Views that read these properties automatically re-render when they change.

### `@Environment` for dependency injection
`FavouritesStore` is created once in `BrewDogApp` and injected into the entire view hierarchy:
```swift
// BrewDogApp.swift — create once
@State private var favourites = FavouritesStore()
ContentView().environment(favourites)

// BeerDetailView.swift — read anywhere in the tree
@Environment(FavouritesStore.self) private var favourites
```
No prop drilling — any view can access the store without it being passed down manually.

### `async`/`await` with `.task` and `Task {}`
```swift
// .task modifier — tied to view lifecycle, cancelled when view disappears
.task {
    await viewModel.fetchBeers()
}

// Task {} inside a Button — fire-and-forget
Button { Task { randomBeer = await viewModel.fetchRandomBeer() } }
```

### `Codable` with `CodingKeys` for snake_case APIs
The Punk API returns `first_brewed`, `brewers_tips`, `food_pairing`. Swift maps these to camelCase:
```swift
enum CodingKeys: String, CodingKey {
    case firstBrewed = "first_brewed"
    case brewersTips = "brewers_tips"
    case foodPairing = "food_pairing"
}
```

### `URLComponents` for safe URL construction
```swift
var components = URLComponents(string: baseURL)!
components.queryItems = [
    URLQueryItem(name: "page", value: "\(page)"),
    URLQueryItem(name: "beer_name", value: name)
]
```
Handles percent-encoding automatically — safer than string interpolation.

### `AsyncImage` with all loading phases
```swift
AsyncImage(url: url) { phase in
    switch phase {
    case .success(let image): image.resizable()...
    case .failure:            placeholder
    case .empty:              ProgressView()
    @unknown default:         placeholder
    }
}
```

### `UserDefaults` persistence
`FavouritesStore` persists both a `Set<Int>` of IDs and the full `[Beer]` JSON so the Favourites tab survives app restarts:
```swift
defaults.set(Array(favouriteIDs), forKey: "favouriteIDs")
defaults.set(try? JSONEncoder().encode(favouriteBeers), forKey: "favouriteBeers")
```

### Decomposing views into private subviews
`BeerDetailView` and `BeerListView` are broken into small private structs to keep `body` readable and avoid SwiftUI's 10-expression limit:
```swift
private struct IngredientsSection: View { ... }
private struct FoodPairingSection: View { ... }
private struct SectionHeader: View { ... }
```

### `ContentUnavailableView`
Used in both `FavouriteView` (empty state) and `RecipeSheetView` (network failure + retry):
```swift
ContentUnavailableView {
    Label("Connection Error", systemImage: "wifi.slash")
} description: {
    Text("Couldn't reach OpenFoodFacts.")
} actions: {
    Button("Retry") { load() }.buttonStyle(.borderedProminent)
}
```

### `presentationDetents` for bottom sheets
```swift
.sheet(isPresented: ...) {
    RecipeSheetView(query: pairing)
        .presentationDetents([.medium, .large])  // draggable half/full sheet
}
```

### `@ViewBuilder` for conditional view composition
```swift
@ViewBuilder
private var brewersTipsSection: some View {
    if let tips = beer.brewersTips, !tips.isEmpty {
        VStack { ... }
    }
    // returns EmptyView if nil — no else branch needed
}
```

### `LazyVGrid` for the grid layout
```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
    ForEach(beers) { beer in ... }
}
```
`Lazy` = only renders cells as they scroll into view.

### Custom `Color` extensions
`Color.brewAmber`, `Color.brewBackground`, `Color.brewCard` — themed colours defined as extensions for consistent branding.

---

## Testing

### Swift Testing framework (`import Testing`)
Uses Apple's new Swift Testing framework (not XCTest) with `@Test`, `#expect`, `#require`:
```swift
@Test("fetchBeers populates beers array on success")
func fetchBeersPopulatesBeers() async throws {
    #expect(viewModel.beers.count == 1)
    #expect(viewModel.beers.first?.name == "Punk IPA")
}
```

### `MockURLProtocol` — network stubbing without a framework
Intercepts `URLSession` at the protocol level — no network calls, fully deterministic:
```swift
MockURLProtocol.requestHandler = { request in
    (HTTPURLResponse(..., statusCode: 200, ...), jsonData)
}
let session = URLSession(configuration: .ephemeral.with(protocolClasses: [MockURLProtocol.self]))
let viewModel = BeerListViewModel(session: session)
```
The ViewModel accepts an injected `URLSession` — this is the testability hook.

### Test coverage
| File | What's tested |
|------|--------------|
| `BeerListViewModelTests` | `fetchBeers` success/failure, query params, `isLoading` state, `fetchRandomBeer` success/failure |
| `BeerModelTests` | `Codable` round-trip, `CodingKeys` mapping, optional fields |
| `FavouritesStoreTests` | toggle add/remove, persistence to UserDefaults, `isFavourite` |
| `FoodProductTests` | `Decodable` mapping from OpenFoodFacts JSON shape |

---

## Requirements

- Xcode 16+
- iOS 17+ (required for `@Observable` macro)
- Swift 5.9+
- No third-party dependencies

## Running the project

```bash
git clone https://github.com/brightmohan/BrewDog.git
open BrewDog.xcodeproj
```

Build and run on any iOS 17+ simulator. No API keys required — both APIs are public.

## Running tests

```bash
# Xcode: Cmd+U
xcodebuild test \
  -project BrewDog.xcodeproj \
  -scheme BrewDog \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
