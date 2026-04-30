import SwiftUI

struct RecipeSheetView: View {
    let query: String

    @State private var product: FoodProduct?
    @State private var isLoading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if failed {
                    ContentUnavailableView {
                        Label("Connection Error", systemImage: "wifi.slash")
                    } description: {
                        Text("Couldn't reach OpenFoodFacts.")
                    } actions: {
                        Button("Retry") { load() }
                            .buttonStyle(.borderedProminent)
                    }
                } else if let product {
                    productDetail(product)
                } else {
                    ContentUnavailableView(
                        "No result found",
                        systemImage: "fork.knife",
                        description: Text("No product matched \"\(query)\" in OpenFoodFacts.")
                    )
                }
            }
            .background(Color.brewBackground)
            .navigationTitle(query)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { load() }
    }

    private func load() {
        isLoading = true
        failed = false
        product = nil
        Task {
            do {
                product = try await RecipeService.search(query: query)
            } catch {
                failed = true
            }
            isLoading = false
        }
    }

    @ViewBuilder
    private func productDetail(_ product: FoodProduct) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                if let url = product.imageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.brewCard
                    }
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                if let name = product.productName {
                    Text(name)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }

                if let n = product.nutriments {
                    nutritionCard(n)
                }
            }
            .padding(.vertical)
        }
    }

    private func nutritionCard(_ n: Nutriments) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition per 100g")
                .font(.headline)
            Divider().overlay(Color.brewAmber.opacity(0.4))
            HStack {
                NutritionCell(label: "Calories", value: n.calories, unit: "kcal")
                NutritionCell(label: "Fat", value: n.fat, unit: "g")
                NutritionCell(label: "Carbs", value: n.carbohydrates, unit: "g")
                NutritionCell(label: "Protein", value: n.proteins, unit: "g")
            }
        }
        .padding()
        .background(Color.brewCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

private struct NutritionCell: View {
    let label: String
    let value: Double?
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let value {
                Text(String(format: "%.1f", value))
                    .font(.subheadline)
                    .bold()
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RecipeSheetView(query: "Chicken Tikka Masala")
}
