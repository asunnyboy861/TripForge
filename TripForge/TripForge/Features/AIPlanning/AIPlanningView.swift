import SwiftUI
import SwiftData

struct AIPlanningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingDays(3)
    @State private var travelStyle: TravelStyle = .balanced
    @State private var budget: Double = 2000
    @State private var hasBudget = true
    @State private var isPlanning = false
    @State private var showResults = false
    @State private var planResult: TripPlanResult?

    private let aiService = AIAgentService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    destinationField
                    dateRangePicker
                    stylePicker
                    budgetSection
                    planButton
                }
                .padding()
            }
            .navigationTitle("AI Trip Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $showResults) {
                if let result = planResult {
                    AIPlanResultView(result: result, destination: destination, startDate: startDate, endDate: endDate)
                }
            }
        }
    }

    private var destinationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Destination", systemImage: "mappin.and.ellipse")
                .font(.headline)
            TextField("Where are you going?", text: $destination)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var dateRangePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Travel Dates", systemImage: "calendar")
                .font(.headline)
            HStack {
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                DatePicker("To", selection: $endDate, in: startDate..., displayedComponents: .date)
            }
        }
    }

    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Travel Style", systemImage: "figure.walk")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TravelStyle.allCases, id: \.self) { style in
                        StyleChip(style: style, isSelected: travelStyle == style) {
                            travelStyle = style
                        }
                    }
                }
            }
        }
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Set Budget", isOn: $hasBudget)
                .font(.headline)
            if hasBudget {
                HStack {
                    Text("$")
                        .font(.title2)
                    TextField("Budget", value: $budget, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                }
                .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var planButton: some View {
        Button {
            startPlanning()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text("Plan My Trip")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(destination.isEmpty ? Color.gray : Color.forgeBlue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(destination.isEmpty || isPlanning)
    }

    private func startPlanning() {
        isPlanning = true
        Task {
            do {
                let result = try await aiService.planTrip(
                    destination: destination,
                    startDate: startDate,
                    endDate: endDate,
                    style: travelStyle,
                    budget: hasBudget ? budget : nil
                )
                planResult = result
                isPlanning = false
                showResults = true
            } catch {
                isPlanning = false
            }
        }
    }
}

struct StyleChip: View {
    let style: TravelStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: style.icon)
                    .font(.title3)
                Text(style.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(isSelected ? Color.forgeBlue : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}

struct AIPlanResultView: View {
    let result: TripPlanResult
    let destination: String
    let startDate: Date
    let endDate: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(result.days) { day in
                    DayResultCard(day: day)
                }

                if !result.tips.isEmpty {
                    TipsCard(tips: result.tips)
                }

                Button {
                    saveTrip()
                } label: {
                    Label("Save This Trip", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.forgeBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("AI Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveTrip() {
        let trip = Trip(title: destination, destination: destination, startDate: startDate, endDate: endDate)
        for dayResult in result.days {
            let dayPlan = DayPlan(date: startDate.addingDays(dayResult.dayIndex), dayIndex: dayResult.dayIndex)
            dayPlan.subtitle = dayResult.subtitle
            for (index, actResult) in dayResult.activities.enumerated() {
                let activity = Activity(
                    title: actResult.title,
                    latitude: actResult.latitude,
                    longitude: actResult.longitude,
                    category: ActivityCategory(rawValue: actResult.category) ?? .other
                )
                activity.subtitle = actResult.subtitle
                activity.duration = actResult.duration
                activity.notes = actResult.notes
                activity.order = index
                dayPlan.activities.append(activity)
            }
            trip.days.append(dayPlan)
        }
        modelContext.insert(trip)
        try? modelContext.save()
        dismiss()
    }
}

extension DayPlanResult: Identifiable {
    var id: Int { dayIndex }
}

struct DayResultCard: View {
    let day: DayPlanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Day \(day.dayIndex + 1)")
                    .font(.headline)
                if let subtitle = day.subtitle {
                    Text("· \(subtitle)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(Array(day.activities.enumerated()), id: \.offset) { _, activity in
                HStack(spacing: 12) {
                    Image(systemName: ActivityCategory(rawValue: activity.category)?.icon ?? "star.fill")
                        .foregroundStyle(Color.categoryColor(hex: ActivityCategory(rawValue: activity.category)?.color ?? "5AC8FA"))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.title)
                            .font(.subheadline.bold())
                        if let subtitle = activity.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(activity.startTime) · \(activity.duration) min")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TipsCard: View {
    let tips: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tips", systemImage: "lightbulb.fill")
                .font(.headline)
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(tip)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.forgeOrange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
