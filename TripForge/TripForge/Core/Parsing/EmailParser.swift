import Foundation
import NaturalLanguage

final class EmailParser {
    struct ParsedBooking {
        let type: BookingType
        let provider: String
        let confirmationCode: String?
        let startDate: Date?
        let endDate: Date?
        let location: String?
        let address: String?
    }

    func parse(emailContent: String) -> ParsedBooking? {
        let bookingType = detectBookingType(from: emailContent)
        let provider = extractProvider(from: emailContent, type: bookingType)
        let confirmationCode = extractConfirmationCode(from: emailContent)
        let dates = extractDates(from: emailContent)
        let location = extractLocation(from: emailContent)

        return ParsedBooking(
            type: bookingType,
            provider: provider,
            confirmationCode: confirmationCode,
            startDate: dates.start,
            endDate: dates.end,
            location: location.name,
            address: location.address
        )
    }

    private func detectBookingType(from content: String) -> BookingType {
        let lower = content.lowercased()
        let flightKeywords = ["flight", "airline", "boarding pass", "departure", "arrival", "gate ", "terminal"]
        let hotelKeywords = ["hotel", "resort", "check-in", "check-out", "room", "night stay", "accommodation"]
        let rentalKeywords = ["car rental", "rental car", "pickup", "drop-off", "vehicle"]
        let trainKeywords = ["train", "rail", "amtrak", "eurostar", "station"]

        if flightKeywords.contains(where: { lower.contains($0) }) { return .flight }
        if hotelKeywords.contains(where: { lower.contains($0) }) { return .hotel }
        if rentalKeywords.contains(where: { lower.contains($0) }) { return .rental }
        if trainKeywords.contains(where: { lower.contains($0) }) { return .train }
        return .other
    }

    private func extractProvider(from content: String, type: BookingType) -> String {
        let patterns: [BookingType: [String]] = [
            .flight: ["United", "Delta", "American Airlines", "Southwest", "JetBlue", "British Airways", "Emirates", "Lufthansa", "Air France", "ANA", "JAL"],
            .hotel: ["Hilton", "Marriott", "Hyatt", "IHG", "Sheraton", "Westin", "Ritz-Carlton", "Four Seasons", "Airbnb", "Booking.com"],
            .rental: ["Hertz", "Enterprise", "Avis", "Budget", "National", "Alamo"]
        ]
        let providers = patterns[type] ?? []
        for provider in providers {
            if content.localizedCaseInsensitiveContains(provider) {
                return provider
            }
        }
        return "Unknown"
    }

    private func extractConfirmationCode(from content: String) -> String? {
        let patterns = [
            "confirmation[:\\s]+([A-Z0-9]{5,8})",
            "booking[:\\s]+([A-Z0-9]{5,8})",
            "reservation[:\\s]+([A-Z0-9]{5,8})",
            "record locator[:\\s]+([A-Z0-9]{5,6})",
            "confirmation code[:\\s]+([A-Z0-9]{5,8})",
            "e-ticket[:\\s]+([0-9]{10,13})"
        ]
        for pattern in patterns {
            if let range = content.range(of: pattern, options: [.regularExpression, .caseInsensitive]),
               let codeRange = content[range].range(of: "[A-Z0-9]{5,13}$", options: [.regularExpression, .caseInsensitive]) {
                return String(content[codeRange])
            }
        }
        return nil
    }

    private func extractDates(from content: String) -> (start: Date?, end: Date?) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(content.startIndex..., in: content)
        let matches = detector?.matches(in: content, range: range) ?? []
        let dates = matches.compactMap { $0.date }
        return (start: dates.first, end: dates.count > 1 ? dates.last : nil)
    }

    private func extractLocation(from content: String) -> (name: String?, address: String?) {
        let addressDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
        let range = NSRange(content.startIndex..., in: content)
        let matches = addressDetector?.matches(in: content, range: range) ?? []
        if let match = matches.first, let components = match.addressComponents {
            let fullAddress = [
                components[.street],
                components[.city],
                components[.state],
                components[.zip]
            ].compactMap { $0 }.joined(separator: ", ")
            return (name: components[.name], address: fullAddress.isEmpty ? nil : fullAddress)
        }
        return (nil, nil)
    }
}
