import SwiftUI
import SwiftData

struct DayTimelineView: View {
    let days: [DayPlan]
    let selectedDayIndex: Int
    @Environment(\.modelContext) private var modelContext
    @State private var showAddActivity = false

    private var currentDay: DayPlan? {
        guard selectedDayIndex < days.count else { return nil }
        return days[selectedDayIndex]
    }

    private var sortedActivities: [Activity] {
        guard let day = currentDay else { return [] }
        return day.activities.sorted { $0.order < $1.order }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let day = currentDay {
                    if let subtitle = day.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                    if sortedActivities.isEmpty {
                        emptyActivities
                    } else {
                        ForEach(Array(sortedActivities.enumerated()), id: \.element.id) { index, activity in
                            ActivityRowView(activity: activity, showConnector: index < sortedActivities.count - 1)
                        }
                    }
                } else {
                    Text("No day selected")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .iPadMaxWidth()
            .padding()
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddActivity = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.forgeBlue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
        .sheet(isPresented: $showAddActivity) {
            if let day = currentDay {
                ActivityEditorView(mode: .addActivity(day: day))
            }
        }
    }

    private var emptyActivities: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No activities yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap + to add activities")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 40)
    }
}

struct ActivityRowView: View {
    let activity: Activity
    let showConnector: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                if let startTime = activity.startTime {
                    Text(startTime.timeString)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Image(systemName: activity.category.icon)
                    .font(.body)
                    .foregroundStyle(Color.categoryColor(hex: activity.category.color))
                    .frame(width: 32, height: 32)
                    .background(Color.categoryColor(hex: activity.category.color).opacity(0.15))
                    .clipShape(Circle())
                if showConnector {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.body.bold())
                    .strikethrough(activity.isCompleted)
                if let subtitle = activity.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    Label("\(activity.duration) min", systemImage: "clock")
                    if activity.latitude != 0 {
                        Label("On map", systemImage: "mappin.circle")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            Spacer()
            Button {
                activity.isCompleted.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(activity.isCompleted ? .green : .secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
