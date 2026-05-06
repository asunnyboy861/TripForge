import SwiftUI

struct BookingsView: View {
    let trip: Trip
    @State private var showImportSheet = false
    @State private var emailContent = ""

    private var sortedBookings: [Booking] {
        trip.bookings.sorted { $0.startDate < $1.startDate }
    }

    var body: some View {
        List {
            ForEach(sortedBookings) { booking in
                BookingRow(booking: booking)
            }
            .onDelete(perform: deleteBooking)

            Section {
                Button {
                    showImportSheet = true
                } label: {
                    Label("Import from Email", systemImage: "envelope.badge.plus")
                }
            }
        }
        .overlay {
            if sortedBookings.isEmpty {
                ContentUnavailableView(
                    "No Bookings",
                    systemImage: "ticket",
                    description: Text("Import booking confirmations from email")
                )
            }
        }
        .sheet(isPresented: $showImportSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Paste your booking confirmation email below")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $emailContent)
                        .frame(minHeight: 200)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .navigationTitle("Import Booking")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showImportSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Import") {
                            importBooking()
                            showImportSheet = false
                        }
                        .disabled(emailContent.isEmpty)
                    }
                }
            }
        }
    }

    private func importBooking() {
        let parser = EmailParser()
        if let parsed = parser.parse(emailContent: emailContent) {
            let booking = Booking(type: parsed.type, provider: parsed.provider, startDate: parsed.startDate ?? Date())
            booking.confirmationCode = parsed.confirmationCode
            booking.endDate = parsed.endDate
            booking.rawEmailContent = emailContent
            trip.bookings.append(booking)
        }
        emailContent = ""
    }

    private func deleteBooking(at offsets: IndexSet) {
        for index in offsets {
            let booking = sortedBookings[index]
            trip.bookings.removeAll { $0.id == booking.id }
        }
    }
}

struct BookingRow: View {
    let booking: Booking

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: booking.type.icon)
                .font(.title3)
                .foregroundStyle(Color.forgeBlue)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(booking.provider)
                    .font(.body.bold())
                Text(booking.startDate.shortDateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let code = booking.confirmationCode {
                    Text("Confirmation: \(code)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
