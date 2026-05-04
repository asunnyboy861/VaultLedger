import SwiftData
import Foundation

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var typeRaw: String
    var category: String
    var subcategory: String?
    var note: String?
    var date: Date
    var accountName: String
    var isRecurring: Bool
    var recurringPeriodRaw: String?
    var attachmentData: Data?
    var createdAt: Date
    var updatedAt: Date

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var recurringPeriod: RecurringPeriod? {
        get { recurringPeriodRaw.flatMap { RecurringPeriod(rawValue: $0) } }
        set { recurringPeriodRaw = newValue?.rawValue }
    }

    enum TransactionType: String, Codable, CaseIterable {
        case income, expense, transfer
    }

    enum RecurringPeriod: String, Codable, CaseIterable {
        case daily, weekly, monthly, yearly
    }

    init(amount: Double, type: TransactionType, category: String, date: Date, accountName: String) {
        self.id = UUID()
        self.amount = amount
        self.typeRaw = type.rawValue
        self.category = category
        self.date = date
        self.accountName = accountName
        self.isRecurring = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
