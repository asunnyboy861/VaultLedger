import Foundation
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amount = ""
    var selectedType: Transaction.TransactionType = .expense
    var selectedCategory: String = "Food"
    var selectedAccount: String = ""
    var selectedDate = Date()
    var note = ""
    var isRecurring = false
    var recurringPeriod: Transaction.RecurringPeriod = .monthly

    var categories: [Category] {
        Category.categories(for: selectedType)
    }

    func save(modelContext: ModelContext) -> Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }

        let accountName = selectedAccount.isEmpty ? "Cash" : selectedAccount
        let transaction = Transaction(
            amount: amountValue,
            type: selectedType,
            category: selectedCategory,
            date: selectedDate,
            accountName: accountName
        )
        transaction.note = note.isEmpty ? nil : note
        transaction.isRecurring = isRecurring
        if isRecurring {
            transaction.recurringPeriod = recurringPeriod
        }

        modelContext.insert(transaction)
        try? modelContext.save()
        return true
    }

    func reset() {
        amount = ""
        selectedType = .expense
        selectedCategory = "Food"
        selectedDate = Date()
        note = ""
        isRecurring = false
        recurringPeriod = .monthly
    }
}
