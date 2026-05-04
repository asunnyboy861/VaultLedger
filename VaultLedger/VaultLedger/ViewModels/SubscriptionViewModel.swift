import Foundation
import SwiftData

@Observable
final class SubscriptionViewModel {
    var detectedSubscriptions: [SubscriptionDetector.DetectedSubscription] = []
    var totalMonthlyCost: Double = 0

    func loadData(modelContext: ModelContext) {
        let allTxns = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        detectedSubscriptions = SubscriptionDetector.detect(transactions: allTxns)
        calculateMonthlyCost()
    }

    private func calculateMonthlyCost() {
        totalMonthlyCost = detectedSubscriptions.reduce(0) { total, sub in
            switch sub.frequency {
            case .weekly: return total + (sub.amount * 4.33)
            case .monthly: return total + sub.amount
            case .quarterly: return total + (sub.amount / 3)
            case .yearly: return total + (sub.amount / 12)
            }
        }
    }
}
