import SwiftUI
import MapKit

struct MapOverviewView: View {
    let days: [DayPlan]
    let selectedDayIndex: Int
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedActivity: Activity?

    private var currentDayActivities: [Activity] {
        guard selectedDayIndex < days.count else { return [] }
        return days[selectedDayIndex].activities.filter { $0.latitude != 0 }
    }

    private var allActivities: [Activity] {
        days.flatMap { $0.activities }.filter { $0.latitude != 0 }
    }

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedActivity) {
            ForEach(allActivities) { activity in
                Annotation(activity.title, coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    ActivityMarker(activity: activity, isCurrentDay: currentDayActivities.contains(where: { $0.id == activity.id }))
                }
                .tag(activity)
            }
            if currentDayActivities.count > 1 {
                MapPolyline(coordinates: currentDayActivities.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                    .stroke(Color.forgeBlue.opacity(0.5), lineWidth: 3)
            }
        }
        .mapStyle(.standard)
        .onChange(of: selectedDayIndex) { _, _ in
            focusOnCurrentDay()
        }
        .onAppear {
            focusOnCurrentDay()
        }
        .overlay(alignment: .bottom) {
            if let activity = selectedActivity {
                ActivityMapPopup(activity: activity)
                    .padding()
            }
        }
    }

    private func focusOnCurrentDay() {
        guard !currentDayActivities.isEmpty else { return }
        let coordinates = currentDayActivities.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        let span = max(latitudes.max()! - latitudes.min()!, longitudes.max()! - longitudes.min()!, 0.01) * 1.5
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        ))
    }
}

struct ActivityMarker: View {
    let activity: Activity
    let isCurrentDay: Bool

    var body: some View {
        Image(systemName: activity.category.icon)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(6)
            .background(isCurrentDay ? Color.categoryColor(hex: activity.category.color) : Color.secondary)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 2)
    }
}

struct ActivityMapPopup: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activity.title)
                .font(.subheadline.bold())
            if let subtitle = activity.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label(activity.category.displayName, systemImage: activity.category.icon)
                    .font(.caption2)
                Label("\(activity.duration) min", systemImage: "clock")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
