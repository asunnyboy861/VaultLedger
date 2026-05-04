import Foundation
import SwiftData

@Observable
final class TransactionListViewModel {
    var transactions: [Transaction] = []
    var searchText = ""
    var selectedType: Transaction.TransactionType?
    var selectedCategory: String?

    var filteredTransactions: [Transaction] {
        var result = transactions
        if !searchText.isEmpty {
            result = result.filter {
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.note?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.accountName.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        return result.sorted { $0.date > $1.date }
    }

    func loadTransactions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        transactions = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteTransaction(_ transaction: Transaction, modelContext: ModelContext) {
        modelContext.delete(transaction)
        try? modelContext.save()
        loadTransactions(modelContext: modelContext)
    }
}
