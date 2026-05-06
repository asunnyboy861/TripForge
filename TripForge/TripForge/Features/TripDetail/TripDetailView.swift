import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    @State private var selectedDayIndex: Int = 0
    @State private var selectedTab: DetailTab = .timeline
    @State private var showAIPlanning = false

    enum DetailTab: String, CaseIterable {
        case timeline = "Timeline"
        case map = "Map"
        case bookings = "Bookings"
        case budget = "Budget"

        var icon: String {
            switch self {
            case .timeline: "calendar"
            case .map: "map"
            case .bookings: "ticket"
            case .budget: "dollarsign.circle"
            }
        }
    }

    private var sortedDays: [DayPlan] {
        trip.days.sorted { $0.dayIndex < $1.dayIndex }
    }

    var body: some View {
        VStack(spacing: 0) {
            dayPicker
            Divider()
            tabContent
            Divider()
            tabBar
        }
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showAIPlanning = true
                } label: {
                    Image(systemName: "sparkles")
                }
            }
        }
        .sheet(isPresented: $showAIPlanning) {
            AIPlanningView()
        }
    }

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(sortedDays.enumerated()), id: \.offset) { index, day in
                    DayPickerItem(day: day, isSelected: selectedDayIndex == index) {
                        selectedDayIndex = index
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .timeline:
                DayTimelineView(days: sortedDays, selectedDayIndex: selectedDayIndex)
            case .map:
                MapOverviewView(days: sortedDays, selectedDayIndex: selectedDayIndex)
            case .bookings:
                BookingsView(trip: trip)
            case .budget:
                BudgetView(trip: trip)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tabBar: some View {
        HStack {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.body)
                        Text(tab.rawValue)
                            .font(.caption2)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.forgeBlue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(.ultraThinMaterial)
    }
}

struct DayPickerItem: View {
    let day: DayPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Day \(day.dayIndex + 1)")
                    .font(.caption.bold())
                Text(day.date.shortDateString)
                    .font(.caption2)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.forgeBlue : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}
