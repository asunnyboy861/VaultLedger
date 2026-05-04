import Foundation
import SwiftData

struct DataExporter {
    static func exportCSV(transactions: [Transaction]) -> Data? {
        var csv = "Date,Type,Category,Amount,Account,Note\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        for txn in transactions {
            let date = dateFormatter.string(from: txn.date)
            let type = txn.type.rawValue
            let category = txn.category
            let amount = String(format: "%.2f", txn.amount)
            let account = txn.accountName
            let note = (txn.note ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            let noteField = note.isEmpty ? "" : "\"\(note)\""
            csv += "\(date),\(type),\(category),\(amount),\(account),\(noteField)\n"
        }

        return csv.data(using: .utf8)
    }
}
