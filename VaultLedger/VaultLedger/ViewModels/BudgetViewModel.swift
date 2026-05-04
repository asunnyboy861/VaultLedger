import Foundation
import SwiftData

@Observable
final class BudgetViewModel {
    var budgets: [Budget] = []
    var newCategory = ""
    var newLimitAmount = ""
    var newPeriod: Budget.BudgetPeriod = .monthly

    func loadBudgets(modelContext: ModelContext) {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == currentMonth && $0.year == currentYear }
        )
        budgets = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addBudget(modelContext: ModelContext) -> Bool {
        guard let limit = Double(newLimitAmount), limit > 0, !newCategory.isEmpty else { return false }

        let now = Date()
        let calendar = Calendar.current
        let budget = Budget(
            category: newCategory,
            limitAmount: limit,
            period: newPeriod,
            month: calendar.component(.month, from: now),
            year: calendar.component(.year, from: now)
        )
        modelContext.insert(budget)
        try? modelContext.save()
        newCategory = ""
        newLimitAmount = ""
        loadBudgets(modelContext: modelContext)
        return true
    }

    func deleteBudget(_ budget: Budget, modelContext: ModelContext) {
        modelContext.delete(budget)
        try? modelContext.save()
        loadBudgets(modelContext: modelContext)
    }
}
