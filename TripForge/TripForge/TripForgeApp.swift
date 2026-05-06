import SwiftUI
import SwiftData

@main
struct TripForgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Trip.self, DayPlan.self, Activity.self, Booking.self])
    }
}
