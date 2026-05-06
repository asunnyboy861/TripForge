import SwiftUI

struct TripCardView: View {
    let trip: Trip

    private var dayCount: Int {
        max(trip.startDate.daysBetween(trip.endDate) + 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.destination)
                .font(.headline)
                .lineLimit(1)
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text("\(trip.startDate.shortDateString) - \(trip.endDate.shortDateString)")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                Image(systemName: "sun.max")
                    .font(.caption2)
                Text("\(dayCount) day\(dayCount == 1 ? "" : "s")")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
