import Foundation
import PDFKit

struct PDFImporter {
    struct ImportedTransaction {
        let date: Date
        let description: String
        let amount: Double
        let type: Transaction.TransactionType
    }

    static func parse(pdfData: Data) -> [ImportedTransaction] {
        guard let pdfDocument = PDFDocument(data: pdfData) else { return [] }
        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            fullText += page.string ?? ""
            fullText += "\n"
        }
        return parseText(fullText)
    }

    private static func parseText(_ text: String) -> [ImportedTransaction] {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var transactions: [ImportedTransaction] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        for line in lines {
            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard components.count >= 3 else { continue }

            var dateFound: Date?
            var amountFound: Double?
            var descriptionParts: [String] = []

            for component in components {
                if dateFound == nil, let date = dateFormatter.date(from: component) {
                    dateFound = date
                } else if let amount = parseAmount(component), amountFound == nil {
                    amountFound = amount
                } else {
                    descriptionParts.append(component)
                }
            }

            if let date = dateFound, let amount = amountFound, !descriptionParts.isEmpty {
                let type: Transaction.TransactionType = amount >= 0 ? .income : .expense
                transactions.append(ImportedTransaction(
                    date: date,
                    description: descriptionParts.joined(separator: " "),
                    amount: abs(amount),
                    type: type
                ))
            }
        }

        return transactions
    }

    private static func parseAmount(_ string: String) -> Double? {
        let cleaned = string
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "(", with: "-")
            .replacingOccurrences(of: ")", with: "")
        return Double(cleaned)
    }
}
