import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    var accounts: [Account] = []
    var isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
    var isPINEnabled = UserDefaults.standard.bool(forKey: "pinEnabled")

    func loadAccounts(modelContext: ModelContext) {
        accounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
    }

    func addAccount(name: String, type: Account.AccountType, balance: Double, modelContext: ModelContext) {
        let account = Account(name: name, type: type, balance: balance)
        if accounts.isEmpty { account.isDefault = true }
        modelContext.insert(account)
        try? modelContext.save()
        loadAccounts(modelContext: modelContext)
    }

    func deleteAccount(_ account: Account, modelContext: ModelContext) {
        modelContext.delete(account)
        try? modelContext.save()
        loadAccounts(modelContext: modelContext)
    }

    func toggleBiometric(_ enabled: Bool) {
        isBiometricEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "biometricEnabled")
    }

    func togglePIN(_ enabled: Bool) {
        isPINEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "pinEnabled")
    }

    func exportData(modelContext: ModelContext) -> Data? {
        let transactions = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        return DataExporter.exportCSV(transactions: transactions)
    }

    func createBackup(modelContext: ModelContext) -> Data? {
        let manager = BackupManager()
        return manager.createBackup(modelContext: modelContext)
    }
}
