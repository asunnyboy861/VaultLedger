import SwiftData
import Foundation

@Model
final class NetWorthSnapshot {
    @Attribute(.unique) var id: UUID
    var date: Date
    var totalAssets: Double
    var totalLiabilities: Double
    var netWorth: Double

    init(date: Date, totalAssets: Double, totalLiabilities: Double) {
        self.id = UUID()
        self.date = date
        self.totalAssets = totalAssets
        self.totalLiabilities = totalLiabilities
        self.netWorth = totalAssets - totalLiabilities
    }
}
