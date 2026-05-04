import SwiftData
import Foundation

@Model
final class Budget: Identifiable {
    @Attribute(.unique) var id: UUID
    var category: String
    var limitAmount: Double
    var periodRaw: String
    var month: Int
    var year: Int

    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRaw) ?? .monthly }
        set { periodRaw = newValue.rawValue }
    }

    enum BudgetPeriod: String, Codable, CaseIterable {
        case monthly, yearly
    }

    init(category: String, limitAmount: Double, period: BudgetPeriod, month: Int, year: Int) {
        self.id = UUID()
        self.category = category
        self.limitAmount = limitAmount
        self.periodRaw = period.rawValue
        self.month = month
        self.year = year
    }
}
