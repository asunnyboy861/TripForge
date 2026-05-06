import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var travelStyleRaw: String
    var budget: Double
    var currency: String
    var coverImageName: String?
    var isShared: Bool
    var shareCode: String?
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \DayPlan.trip) var days: [DayPlan]
    @Relationship(deleteRule: .cascade, inverse: \Booking.trip) var bookings: [Booking]

    var travelStyle: TravelStyle {
        get { TravelStyle(rawValue: travelStyleRaw) ?? .balanced }
        set { travelStyleRaw = newValue.rawValue }
    }

    init(title: String, destination: String, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.travelStyleRaw = TravelStyle.balanced.rawValue
        self.budget = 0
        self.currency = "USD"
        self.isShared = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.days = []
        self.bookings = []
    }
}

@Model
final class DayPlan {
    var id: UUID
    var date: Date
    var dayIndex: Int
    var subtitle: String?
    @Relationship(deleteRule: .cascade, inverse: \Activity.dayPlan) var activities: [Activity]
    var trip: Trip?

    init(date: Date, dayIndex: Int) {
        self.id = UUID()
        self.date = date
        self.dayIndex = dayIndex
        self.activities = []
    }
}

@Model
final class Activity {
    var id: UUID
    var title: String
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    var startTime: Date?
    var endTime: Date?
    var duration: Int
    var categoryRaw: String
    var notes: String?
    var isCompleted: Bool
    var order: Int
    var dayPlan: DayPlan?

    var category: ActivityCategory {
        get { ActivityCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(title: String, latitude: Double, longitude: Double, category: ActivityCategory) {
        self.id = UUID()
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.categoryRaw = category.rawValue
        self.duration = 60
        self.isCompleted = false
        self.order = 0
    }
}

@Model
final class Booking {
    var id: UUID
    var typeRaw: String
    var provider: String
    var confirmationCode: String?
    var startDate: Date
    var endDate: Date?
    var latitude: Double?
    var longitude: Double?
    var rawEmailContent: String?
    var trip: Trip?

    var type: BookingType {
        get { BookingType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }

    init(type: BookingType, provider: String, startDate: Date) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.provider = provider
        self.startDate = startDate
    }
}

enum TravelStyle: String, Codable, CaseIterable {
    case relaxed = "relaxed"
    case balanced = "balanced"
    case packed = "packed"
    case adventure = "adventure"
    case cultural = "cultural"

    var displayName: String {
        switch self {
        case .relaxed: "Relaxed"
        case .balanced: "Balanced"
        case .packed: "Packed"
        case .adventure: "Adventure"
        case .cultural: "Cultural"
        }
    }

    var icon: String {
        switch self {
        case .relaxed: "leaf.fill"
        case .balanced: "scale.3d.fill"
        case .packed: "bolt.fill"
        case .adventure: "mountain.2.fill"
        case .cultural: "theatermasks.fill"
        }
    }
}

enum ActivityCategory: String, Codable, CaseIterable {
    case sightseeing = "sightseeing"
    case dining = "dining"
    case shopping = "shopping"
    case transport = "transport"
    case accommodation = "accommodation"
    case entertainment = "entertainment"
    case nature = "nature"
    case other = "other"

    var displayName: String {
        switch self {
        case .sightseeing: "Sightseeing"
        case .dining: "Dining"
        case .shopping: "Shopping"
        case .transport: "Transport"
        case .accommodation: "Accommodation"
        case .entertainment: "Entertainment"
        case .nature: "Nature"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .sightseeing: "mappin.and.ellipse"
        case .dining: "fork.knife"
        case .shopping: "bag.fill"
        case .transport: "car.fill"
        case .accommodation: "bed.double.fill"
        case .entertainment: "ticket.fill"
        case .nature: "leaf.fill"
        case .other: "star.fill"
        }
    }

    var color: String {
        switch self {
        case .sightseeing: "007AFF"
        case .dining: "FF9500"
        case .shopping: "FF2D55"
        case .transport: "8E8E93"
        case .accommodation: "AF52DE"
        case .entertainment: "FFCC00"
        case .nature: "34C759"
        case .other: "5AC8FA"
        }
    }
}

enum BookingType: String, Codable, CaseIterable {
    case flight = "flight"
    case hotel = "hotel"
    case rental = "rental"
    case train = "train"
    case restaurant = "restaurant"
    case other = "other"

    var icon: String {
        switch self {
        case .flight: "airplane"
        case .hotel: "bed.double.fill"
        case .rental: "car.fill"
        case .train: "train.side.front.car"
        case .restaurant: "fork.knife"
        case .other: "doc.fill"
        }
    }
}
