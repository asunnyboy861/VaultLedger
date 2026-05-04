import Foundation
import SwiftData

@Observable
final class BackupManager {
    var isBackingUp = false
    var lastBackupDate: Date?

    func createBackup(modelContext: ModelContext) -> Data? {
        isBackingUp = true
        defer { isBackingUp = false }

        do {
            let transactions = try modelContext.fetch(FetchDescriptor<Transaction>())
            let accounts = try modelContext.fetch(FetchDescriptor<Account>())
            let budgets = try modelContext.fetch(FetchDescriptor<Budget>())
            let snapshots = try modelContext.fetch(FetchDescriptor<NetWorthSnapshot>())

            let backup = BackupData(
                transactions: transactions.map { TransactionBackup($0) },
                accounts: accounts.map { AccountBackup($0) },
                budgets: budgets.map { BudgetBackup($0) },
                netWorthSnapshots: snapshots.map { NetWorthBackup($0) },
                exportDate: Date()
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(backup)
            lastBackupDate = Date()
            return data
        } catch {
            return nil
        }
    }

    func restoreBackup(data: Data, modelContext: ModelContext) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backup = try decoder.decode(BackupData.self, from: data)

            let existingTxns = try modelContext.fetch(FetchDescriptor<Transaction>())
            let existingAccounts = try modelContext.fetch(FetchDescriptor<Account>())
            let existingBudgets = try modelContext.fetch(FetchDescriptor<Budget>())
            let existingSnapshots = try modelContext.fetch(FetchDescriptor<NetWorthSnapshot>())

            for txn in existingTxns { modelContext.delete(txn) }
            for account in existingAccounts { modelContext.delete(account) }
            for budget in existingBudgets { modelContext.delete(budget) }
            for snapshot in existingSnapshots { modelContext.delete(snapshot) }

            for accountBackup in backup.accounts {
                let account = Account(name: accountBackup.name, type: Account.AccountType(rawValue: accountBackup.typeRaw) ?? .checking, balance: accountBackup.balance, currency: accountBackup.currency)
                account.id = accountBackup.id
                account.icon = accountBackup.icon
                account.colorHex = accountBackup.colorHex
                account.isDefault = accountBackup.isDefault
                modelContext.insert(account)
            }

            for txnBackup in backup.transactions {
                let txn = Transaction(amount: txnBackup.amount, type: Transaction.TransactionType(rawValue: txnBackup.typeRaw) ?? .expense, category: txnBackup.category, date: txnBackup.date, accountName: txnBackup.accountName)
                txn.id = txnBackup.id
                txn.subcategory = txnBackup.subcategory
                txn.note = txnBackup.note
                txn.isRecurring = txnBackup.isRecurring
                txn.recurringPeriodRaw = txnBackup.recurringPeriodRaw
                txn.createdAt = txnBackup.createdAt
                txn.updatedAt = txnBackup.updatedAt
                modelContext.insert(txn)
            }

            for budgetBackup in backup.budgets {
                let budget = Budget(category: budgetBackup.category, limitAmount: budgetBackup.limitAmount, period: Budget.BudgetPeriod(rawValue: budgetBackup.periodRaw) ?? .monthly, month: budgetBackup.month, year: budgetBackup.year)
                budget.id = budgetBackup.id
                modelContext.insert(budget)
            }

            for snapshotBackup in backup.netWorthSnapshots {
                let snapshot = NetWorthSnapshot(date: snapshotBackup.date, totalAssets: snapshotBackup.totalAssets, totalLiabilities: snapshotBackup.totalLiabilities)
                snapshot.id = snapshotBackup.id
                modelContext.insert(snapshot)
            }

            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
}

struct BackupData: Codable {
    let transactions: [TransactionBackup]
    let accounts: [AccountBackup]
    let budgets: [BudgetBackup]
    let netWorthSnapshots: [NetWorthBackup]
    let exportDate: Date
}

struct TransactionBackup: Codable {
    let id: UUID
    let amount: Double
    let typeRaw: String
    let category: String
    let subcategory: String?
    let note: String?
    let date: Date
    let accountName: String
    let isRecurring: Bool
    let recurringPeriodRaw: String?
    let createdAt: Date
    let updatedAt: Date

    init(_ txn: Transaction) {
        self.id = txn.id
        self.amount = txn.amount
        self.typeRaw = txn.typeRaw
        self.category = txn.category
        self.subcategory = txn.subcategory
        self.note = txn.note
        self.date = txn.date
        self.accountName = txn.accountName
        self.isRecurring = txn.isRecurring
        self.recurringPeriodRaw = txn.recurringPeriodRaw
        self.createdAt = txn.createdAt
        self.updatedAt = txn.updatedAt
    }
}

struct AccountBackup: Codable {
    let id: UUID
    let name: String
    let typeRaw: String
    let balance: Double
    let currency: String
    let icon: String
    let colorHex: String
    let isDefault: Bool

    init(_ account: Account) {
        self.id = account.id
        self.name = account.name
        self.typeRaw = account.typeRaw
        self.balance = account.balance
        self.currency = account.currency
        self.icon = account.icon
        self.colorHex = account.colorHex
        self.isDefault = account.isDefault
    }
}

struct BudgetBackup: Codable {
    let id: UUID
    let category: String
    let limitAmount: Double
    let periodRaw: String
    let month: Int
    let year: Int

    init(_ budget: Budget) {
        self.id = budget.id
        self.category = budget.category
        self.limitAmount = budget.limitAmount
        self.periodRaw = budget.periodRaw
        self.month = budget.month
        self.year = budget.year
    }
}

struct NetWorthBackup: Codable {
    let id: UUID
    let date: Date
    let totalAssets: Double
    let totalLiabilities: Double
    let netWorth: Double

    init(_ snapshot: NetWorthSnapshot) {
        self.id = snapshot.id
        self.date = snapshot.date
        self.totalAssets = snapshot.totalAssets
        self.totalLiabilities = snapshot.totalLiabilities
        self.netWorth = snapshot.netWorth
    }
}
