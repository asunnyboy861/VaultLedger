import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    var totalBalance: Double = 0
    var monthlyIncome: Double = 0
    var monthlyExpenses: Double = 0
    var recentTransactions: [Transaction] = []
    var detectedSubscriptions: [SubscriptionDetector.DetectedSubscription] = []
    var budgetProgress: [BudgetProgressItem] = []

    struct BudgetProgressItem: Identifiable {
        let id = UUID()
        let category: String
        let spent: Double
        let limit: Double
        var progress: Double {
            limit > 0 ? spent / limit : 0
        }
    }

    func loadData(modelContext: ModelContext) {
        let now = Date()
        let startOfMonth = now.startOfMonth

        let allAccounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
        totalBalance = allAccounts.reduce(0) { $0 + $1.balance }

        let txnDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.date >= startOfMonth }
        )
        let monthlyTxns = (try? modelContext.fetch(txnDescriptor)) ?? []
        monthlyIncome = monthlyTxns.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        monthlyExpenses = monthlyTxns.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }

        let recentDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        recentTransactions = ((try? modelContext.fetch(recentDescriptor)) ?? []).prefix(10).map { $0 }

        let allTxns = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        detectedSubscriptions = SubscriptionDetector.detect(transactions: allTxns)

        loadBudgetProgress(modelContext: modelContext)
    }

    private func loadBudgetProgress(modelContext: ModelContext) {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let budgetDescriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == currentMonth && $0.year == currentYear }
        )
        let budgets = (try? modelContext.fetch(budgetDescriptor)) ?? []

        let startOfMonth = now.startOfMonth
        let txnDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.typeRaw == "expense" && $0.date >= startOfMonth }
        )
        let expenses = (try? modelContext.fetch(txnDescriptor)) ?? []

        var progressItems: [BudgetProgressItem] = []
        for budget in budgets {
            let spent = expenses.filter { $0.category == budget.category }.reduce(0) { $0 + $1.amount }
            progressItems.append(BudgetProgressItem(category: budget.category, spent: spent, limit: budget.limitAmount))
        }
        budgetProgress = progressItems
    }
}
