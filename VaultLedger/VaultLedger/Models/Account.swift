import SwiftData
import Foundation

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var balance: Double
    var currency: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    var createdAt: Date

    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .checking }
        set { typeRaw = newValue.rawValue }
    }

    enum AccountType: String, Codable, CaseIterable {
        case checking, savings, creditCard, cash, investment, other

        var displayName: String {
            switch self {
            case .checking: return "Checking"
            case .savings: return "Savings"
            case .creditCard: return "Credit Card"
            case .cash: return "Cash"
            case .investment: return "Investment"
            case .other: return "Other"
            }
        }

        var systemIcon: String {
            switch self {
            case .checking: return "banknote"
            case .savings: return "piggybank"
            case .creditCard: return "creditcard"
            case .cash: return "dollarsign.circle"
            case .investment: return "chart.line.uptrend.xyaxis"
            case .other: return "wallet.pass"
            }
        }
    }

    init(name: String, type: AccountType, balance: Double, currency: String = "USD") {
        self.id = UUID()
        self.name = name
        self.typeRaw = type.rawValue
        self.balance = balance
        self.currency = currency
        self.icon = type.systemIcon
        self.colorHex = "#007AFF"
        self.isDefault = false
        self.createdAt = Date()
    }
}
