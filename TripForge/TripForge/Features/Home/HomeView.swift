import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @State private var showNewTrip = false
    @State private var showAIPlanning = false

    private var upcomingTrips: [Trip] {
        trips.filter { $0.endDate >= Date() }.sorted { $0.startDate < $1.startDate }
    }

    private var pastTrips: [Trip] {
        trips.filter { $0.endDate < Date() }.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    aiEntryCard
                    if !upcomingTrips.isEmpty {
                        tripSection(title: "Upcoming Trips", trips: upcomingTrips)
                    }
                    if !pastTrips.isEmpty {
                        tripSection(title: "Past Trips", trips: pastTrips)
                    }
                    if trips.isEmpty {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("TripForge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewTrip) {
                ActivityEditorView(mode: .newTrip)
            }
            .sheet(isPresented: $showAIPlanning) {
                AIPlanningView()
            }
        }
    }

    private var aiEntryCard: some View {
        Button {
            showAIPlanning = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Text("AI Plan Your Trip")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                Text("Where are you going?")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Enter destination...")
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
                .padding(10)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            .background(
                LinearGradient(colors: [.forgeBlue, .forgeTeal], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func tripSection(title: String, trips: [Trip]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripCardView(trip: trip)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.desk")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No trips yet")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Create your first trip or let AI plan one for you")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}
