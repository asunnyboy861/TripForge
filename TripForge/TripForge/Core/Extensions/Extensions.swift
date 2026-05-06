import SwiftUI

extension Color {
    static let forgeBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
    static let forgeTeal = Color(red: 90/255, green: 200/255, blue: 250/255)
    static let forgeOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let aiPurple = Color(red: 175/255, green: 82/255, blue: 222/255)

    static func categoryColor(hex: String) -> Color {
        guard let intVal = Int(hex, radix: 16) else { return .blue }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}

extension Date {
    var shortDateString: String {
        formatted(.dateTime.month(.abbreviated).day())
    }

    var fullDateString: String {
        formatted(.dateTime.month(.wide).day().year())
    }

    var weekdayString: String {
        formatted(.dateTime.weekday(.wide))
    }

    var timeString: String {
        formatted(.dateTime.hour().minute())
    }

    func daysBetween(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: other).day ?? 0
    }

    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

extension View {
    func iPadMaxWidth() -> some View {
        self.frame(maxWidth: 720).frame(maxWidth: .infinity)
    }
}
