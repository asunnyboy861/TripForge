import SwiftUI

struct BudgetView: View {
    let trip: Trip

    private var totalBudget: Double {
        trip.budget
    }

    private var spentByCategory: [ActivityCategory: Double] {
        var result: [ActivityCategory: Double] = [:]
        for day in trip.days {
            for activity in day.activities {
                result[activity.category, default: 0] += 0
            }
        }
        return result
    }

    var body: some View {
        List {
            Section("Budget Overview") {
                HStack {
                    Text("Total Budget")
                    Spacer()
                    Text("\(trip.currency) \(totalBudget, specifier: "%.0f")")
                        .bold()
                }
            }

            Section("Spending by Category") {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(Color.categoryColor(hex: category.color))
                        Text(category.displayName)
                        Spacer()
                        Text("\(trip.currency) 0")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                NavigationLink {
                    Text("Budget tracking coming soon")
                } label: {
                    Label("Add Expense", systemImage: "plus.circle")
                }
            }
        }
    }
}
