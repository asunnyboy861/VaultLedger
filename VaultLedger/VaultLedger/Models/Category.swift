import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let type: Transaction.TransactionType

    static let expenseCategories: [Category] = [
        Category(name: "Food", icon: "fork.knife", colorHex: "#FF6B6B", type: .expense),
        Category(name: "Transport", icon: "car.fill", colorHex: "#4ECDC4", type: .expense),
        Category(name: "Housing", icon: "house.fill", colorHex: "#45B7D1", type: .expense),
        Category(name: "Shopping", icon: "bag.fill", colorHex: "#DDA0DD", type: .expense),
        Category(name: "Entertainment", icon: "gamecontroller.fill", colorHex: "#96CEB4", type: .expense),
        Category(name: "Health", icon: "heart.fill", colorHex: "#FF8A80", type: .expense),
        Category(name: "Education", icon: "book.fill", colorHex: "#82B1FF", type: .expense),
        Category(name: "Utilities", icon: "bolt.fill", colorHex: "#FFD54F", type: .expense),
        Category(name: "Phone", icon: "iphone", colorHex: "#B388FF", type: .expense),
        Category(name: "Subscriptions", icon: "arrow.triangle.2.circlepath", colorHex: "#FF80AB", type: .expense),
        Category(name: "Other", icon: "ellipsis.circle.fill", colorHex: "#8E8E93", type: .expense)
    ]

    static let incomeCategories: [Category] = [
        Category(name: "Salary", icon: "briefcase.fill", colorHex: "#00D09C", type: .income),
        Category(name: "Freelance", icon: "laptopcomputer", colorHex: "#4ECDC4", type: .income),
        Category(name: "Investment", icon: "chart.line.uptrend.xyaxis", colorHex: "#45B7D1", type: .income),
        Category(name: "Gift", icon: "gift.fill", colorHex: "#DDA0DD", type: .income),
        Category(name: "Refund", icon: "arrow.uturn.backward", colorHex: "#FFD54F", type: .income),
        Category(name: "Other", icon: "ellipsis.circle.fill", colorHex: "#8E8E93", type: .income)
    ]

    static func categories(for type: Transaction.TransactionType) -> [Category] {
        switch type {
        case .expense: return expenseCategories
        case .income: return incomeCategories
        case .transfer: return expenseCategories
        }
    }
}
