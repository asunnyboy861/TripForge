import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Trips", systemImage: "globe")
                }
                .tag(0)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Trip.self, inMemory: true)
}
