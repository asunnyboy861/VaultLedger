import Foundation

struct SubscriptionDetector {
    struct DetectedSubscription: Identifiable {
        let id = UUID()
        let merchant: String
        let amount: Double
        let frequency: SubscriptionFrequency
        let confidence: Double
        let lastDate: Date
        let nextEstimatedDate: Date
    }

    enum SubscriptionFrequency {
        case monthly, yearly, weekly, quarterly
    }

    static func detect(transactions: [Transaction], minOccurrences: Int = 2) -> [DetectedSubscription] {
        let expenses = transactions.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: expenses) { transaction in
            normalizeMerchant(transaction.category)
        }

        var subscriptions: [DetectedSubscription] = []

        for (merchant, txns) in grouped where txns.count >= minOccurrences {
            let sorted = txns.sorted { $0.date < $1.date }
            let amounts = sorted.map { $0.amount }
            let medianAmount = median(amounts)

            let similarAmounts = amounts.filter { abs($0 - medianAmount) / medianAmount < 0.15 }
            guard similarAmounts.count >= minOccurrences else { continue }

            let intervals = zip(sorted.dropFirst(), sorted).map { $0.date.timeIntervalSince($1.date) }
            guard let detectedFrequency = detectFrequency(intervals: intervals) else { continue }

            let confidence = Double(similarAmounts.count) / Double(sorted.count)
            guard confidence >= 0.6 else { continue }

            let nextDate = estimateNextDate(lastDate: sorted.last!.date, frequency: detectedFrequency)

            subscriptions.append(DetectedSubscription(
                merchant: merchant,
                amount: medianAmount,
                frequency: detectedFrequency,
                confidence: confidence,
                lastDate: sorted.last!.date,
                nextEstimatedDate: nextDate
            ))
        }

        return subscriptions.sorted { $0.confidence > $1.confidence }
    }

    private static func normalizeMerchant(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " #\\d+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }

    private static func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }

    private static func detectFrequency(intervals: [TimeInterval]) -> SubscriptionFrequency? {
        guard !intervals.isEmpty else { return nil }
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let dayInterval = avgInterval / 86400

        if dayInterval < 10 { return .weekly }
        if dayInterval > 20 && dayInterval < 40 { return .monthly }
        if dayInterval > 80 && dayInterval < 100 { return .quarterly }
        if dayInterval > 340 && dayInterval < 390 { return .yearly }
        return nil
    }

    private static func estimateNextDate(lastDate: Date, frequency: SubscriptionFrequency) -> Date {
        let calendar = Calendar.current
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: lastDate) ?? lastDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: lastDate) ?? lastDate
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: lastDate) ?? lastDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: lastDate) ?? lastDate
        }
    }
}

extension SubscriptionDetector.SubscriptionFrequency {
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        }
    }
}
