import Foundation
import SwiftData

struct CSVImporter {
    enum BankPreset: String, CaseIterable {
        case chase = "Chase"
        case bankOfAmerica = "Bank of America"
        case wellsFargo = "Wells Fargo"
        case citi = "Citibank"
        case custom = "Custom"

        var columnMapping: CSVColumnMapping {
            switch self {
            case .chase:
                return CSVColumnMapping(date: 0, description: 2, amount: 5, type: 4)
            case .bankOfAmerica:
                return CSVColumnMapping(date: 0, description: 1, amount: 2, type: 3)
            case .wellsFargo:
                return CSVColumnMapping(date: 0, description: 4, amount: 1, type: nil)
            case .citi:
                return CSVColumnMapping(date: 1, description: 3, amount: 5, type: nil)
            case .custom:
                return CSVColumnMapping(date: 0, description: 1, amount: 2, type: 3)
            }
        }
    }

    struct CSVColumnMapping {
        let date: Int
        let description: Int
        let amount: Int
        let type: Int?
    }

    struct ImportedTransaction {
        let date: Date
        let description: String
        let amount: Double
        let type: Transaction.TransactionType
    }

    static func parse(csvData: Data, preset: BankPreset, encoding: String.Encoding = .utf8) -> [ImportedTransaction] {
        guard let content = String(data: csvData, encoding: encoding) else { return [] }
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        let mapping = preset.columnMapping
        var transactions: [ImportedTransaction] = []

        for line in lines.dropFirst() {
            let columns = parseCSVLine(line)
            guard columns.count > max(mapping.date, mapping.description, mapping.amount) else { continue }

            let dateStr = columns[mapping.date].trimmingCharacters(in: .whitespaces)
            let desc = columns[mapping.description].trimmingCharacters(in: .whitespaces)
            let amountStr = columns[mapping.amount].trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")

            guard let amount = Double(amountStr), let date = parseDate(dateStr) else { continue }

            var type: Transaction.TransactionType = .expense
            if let typeCol = mapping.type, columns.count > typeCol {
                let typeStr = columns[typeCol].lowercased()
                type = typeStr.contains("credit") || typeStr.contains("income") ? .income : .expense
            } else {
                type = amount >= 0 ? .income : .expense
            }

            transactions.append(ImportedTransaction(
                date: date,
                description: desc,
                amount: abs(amount),
                type: type
            ))
        }

        return transactions
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }

    private static func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        let formats = ["MM/dd/yyyy", "yyyy-MM-dd", "MM/dd/yy", "dd/MM/yyyy"]
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string.trimmingCharacters(in: .whitespaces)) {
                return date
            }
        }
        return nil
    }
}
