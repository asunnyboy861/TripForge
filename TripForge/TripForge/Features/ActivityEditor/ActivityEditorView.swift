import SwiftUI
import SwiftData

struct ActivityEditorView: View {
    enum EditorMode {
        case newTrip
        case addActivity(day: DayPlan)
        case editActivity(Activity)
    }

    let mode: EditorMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var tripTitle = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingDays(3)

    @State private var activityTitle = ""
    @State private var activitySubtitle = ""
    @State private var activityCategory: ActivityCategory = .sightseeing
    @State private var activityDuration = 60
    @State private var activityNotes = ""

    var body: some View {
        NavigationStack {
            Form {
                switch mode {
                case .newTrip:
                    newTripForm
                case .addActivity:
                    activityForm
                case .editActivity:
                    activityForm
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                if case .editActivity(let activity) = mode {
                    activityTitle = activity.title
                    activitySubtitle = activity.subtitle ?? ""
                    activityCategory = activity.category
                    activityDuration = activity.duration
                    activityNotes = activity.notes ?? ""
                }
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .newTrip: "New Trip"
        case .addActivity: "Add Activity"
        case .editActivity: "Edit Activity"
        }
    }

    private var isValid: Bool {
        switch mode {
        case .newTrip:
            return !tripTitle.isEmpty && !destination.isEmpty
        case .addActivity, .editActivity:
            return !activityTitle.isEmpty
        }
    }

    private var newTripForm: some View {
        Group {
            Section("Trip Details") {
                TextField("Trip Name", text: $tripTitle)
                TextField("Destination", text: $destination)
            }
            Section("Dates") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
            }
        }
    }

    private var activityForm: some View {
        Group {
            Section("Activity") {
                TextField("Title", text: $activityTitle)
                TextField("Subtitle (optional)", text: $activitySubtitle)
                Picker("Category", selection: $activityCategory) {
                    ForEach(ActivityCategory.allCases, id: \.self) { cat in
                        Label(cat.displayName, systemImage: cat.icon).tag(cat)
                    }
                }
            }
            Section("Details") {
                Stepper("Duration: \(activityDuration) min", value: $activityDuration, in: 15...480, step: 15)
                TextField("Notes (optional)", text: $activityNotes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    private func save() {
        switch mode {
        case .newTrip:
            let trip = Trip(title: tripTitle, destination: destination, startDate: startDate, endDate: endDate)
            let dayCount = max(startDate.daysBetween(endDate) + 1, 1)
            for i in 0..<dayCount {
                let dayPlan = DayPlan(date: startDate.addingDays(i), dayIndex: i)
                trip.days.append(dayPlan)
            }
            modelContext.insert(trip)
        case .addActivity(let day):
            let activity = Activity(title: activityTitle, latitude: 0, longitude: 0, category: activityCategory)
            activity.subtitle = activitySubtitle.isEmpty ? nil : activitySubtitle
            activity.duration = activityDuration
            activity.notes = activityNotes.isEmpty ? nil : activityNotes
            activity.order = day.activities.count
            day.activities.append(activity)
        case .editActivity(let activity):
            activity.title = activityTitle
            activity.subtitle = activitySubtitle.isEmpty ? nil : activitySubtitle
            activity.categoryRaw = activityCategory.rawValue
            activity.duration = activityDuration
            activity.notes = activityNotes.isEmpty ? nil : activityNotes
        }
        try? modelContext.save()
        dismiss()
    }
}
