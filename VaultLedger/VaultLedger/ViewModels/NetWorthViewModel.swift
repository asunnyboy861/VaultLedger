import Foundation
import SwiftData

@Observable
final class NetWorthViewModel {
    var snapshots: [NetWorthSnapshot] = []
    var totalAssets: Double = 0
    var totalLiabilities: Double = 0
    var currentNetWorth: Double = 0

    func loadData(modelContext: ModelContext) {
        let accounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
        totalAssets = accounts.filter { $0.type != .creditCard }.reduce(0) { $0 + $1.balance }
        totalLiabilities = accounts.filter { $0.type == .creditCard }.reduce(0) { $0 + abs($1.balance) }
        currentNetWorth = totalAssets - totalLiabilities

        let descriptor = FetchDescriptor<NetWorthSnapshot>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        snapshots = (try? modelContext.fetch(descriptor)) ?? []

        saveSnapshot(modelContext: modelContext)
    }

    private func saveSnapshot(modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        let existingToday = snapshots.first { calendar.isDate($0.date, inSameDayAs: today) }
        if let existing = existingToday {
            existing.totalAssets = totalAssets
            existing.totalLiabilities = totalLiabilities
            existing.netWorth = currentNetWorth
        } else {
            let snapshot = NetWorthSnapshot(date: today, totalAssets: totalAssets, totalLiabilities: totalLiabilities)
            modelContext.insert(snapshot)
        }
        try? modelContext.save()
    }
}
