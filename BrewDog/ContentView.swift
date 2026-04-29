import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            BeerListView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            FavouriteView()
                .tabItem{
                    Label("Favourites", systemImage: "heart")
                }
        }
        
    }
}

#Preview {
    ContentView()
}
