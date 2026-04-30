import SwiftUI

struct BeerDetailView: View {
    let beer: Beer
    @Environment(FavouritesStore.self) private var favourites
    @State private var selectedPairing: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BeerImageView(url: beer.imageURL, height: 280)
                nameHeader
                Group {
                    metadata
                    descriptionSection
                    ingredientsSection
                    brewersTipsSection
                    foodPairingSection
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(Color.brewBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var nameHeader: some View {
        HStack {
            Text(beer.name)
                .font(.title)
                .bold()
            Spacer()
            Button {
                favourites.toggle(beer)
            } label: {
                Image(systemName: favourites.isFavourite(beer) ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundStyle(favourites.isFavourite(beer) ? .red : .secondary)
            }
        }
        .padding(.horizontal)
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(beer.tagline)
                .font(.title3)
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                if let abv = beer.abv {
                    Label(String(format: "ABV: %.1f%%", abv), systemImage: "percent")
                }
                if let ibu = beer.ibu {
                    Label(String(format: "IBU: %.0f", ibu), systemImage: "flame")
                }
            }
            .font(.subheadline)
            Label("First brewed: \(beer.firstBrewed)", systemImage: "calendar")
                .font(.subheadline)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "Description")
            Text(beer.description)
                .font(.body)
        }
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        if let ingredients = beer.ingredients {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Ingredients")
                if let malts = ingredients.malt, !malts.isEmpty {
                    IngredientGroup(heading: "Malt") {
                        ForEach(malts, id: \.name) { malt in
                            IngredientRow(name: malt.name, amount: malt.amount)
                        }
                    }
                }
                if let hops = ingredients.hops, !hops.isEmpty {
                    IngredientGroup(heading: "Hops") {
                        ForEach(Array(hops.enumerated()), id: \.offset) { _, hop in
                            IngredientRow(name: hop.name, amount: hop.amount, detail: hop.add)
                        }
                    }
                }
                if let yeast = ingredients.yeast {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yeast").font(.subheadline).bold()
                        Text(yeast).font(.body)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var brewersTipsSection: some View {
        if let tips = beer.brewersTips, !tips.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                SectionHeader(title: "Brewer's Tips")
                Text(tips).font(.body)
            }
        }
    }

    @ViewBuilder
    private var foodPairingSection: some View {
        if let pairings = beer.foodPairing, !pairings.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                SectionHeader(title: "Food Pairing")
                ForEach(pairings, id: \.self) { pairing in
                    Button {
                        selectedPairing = pairing
                    } label: {
                        Label(pairing, systemImage: "fork.knife")
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedPairing != nil },
                set: { if !$0 { selectedPairing = nil } }
            )) {
                if let pairing = selectedPairing {
                    RecipeSheetView(query: pairing)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top, 4)
        Divider()
            .overlay(Color.brewAmber.opacity(0.4))
    }
}

private struct IngredientGroup<Content: View>: View {
    let heading: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(heading).font(.subheadline).bold()
            content
        }
    }
}

private struct IngredientRow: View {
    let name: String
    let amount: Amount
    var detail: String?

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(String(format: "%.1f", amount.value)) \(amount.unit)")
                .foregroundStyle(.secondary)
            if let detail {
                Text("(\(detail))")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        BeerDetailView(beer: Beer(
            id: 1,
            name: "Buzz",
            tagline: "A Real Bitter Experience.",
            firstBrewed: "09/2007",
            description: "A light, crisp and bitter IPA brewed with English and American hops.",
            image: nil,
            abv: 4.5,
            ibu: 60,
            ingredients: nil,
            brewersTips: "The earthy and floral aromas from the hops can be overpowering.",
            foodPairing: ["Spicy chicken tikka masala", "Grilled chicken quesadilla"]
        ))
    }
    .environment(FavouritesStore())
}
