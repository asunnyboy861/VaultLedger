import Foundation
import SwiftData
import UniformTypeIdentifiers

@Observable
final class ImportViewModel {
    var selectedBank: CSVImporter.BankPreset = .chase
    var importedTransactions: [CSVImporter.ImportedTransaction] = []
    var isImporting = false
    var importError: String?
    var showFilePicker = false
    var showPDFPicker = false

    func importCSV(modelContext: ModelContext) {
        showFilePicker = true
    }

    func importPDF() {
        showPDFPicker = true
    }

    func processCSVData(_ data: Data, modelContext: ModelContext) {
        isImporting = true
        importError = nil
        importedTransactions = CSVImporter.parse(csvData: data, preset: selectedBank)
        isImporting = false
    }

    func processPDFData(_ data: Data, modelContext: ModelContext) {
        isImporting = true
        importError = nil
        let pdfTransactions = PDFImporter.parse(pdfData: data)
        importedTransactions = pdfTransactions.map { txn in
            CSVImporter.ImportedTransaction(
                date: txn.date,
                description: txn.description,
                amount: txn.amount,
                type: txn.type
            )
        }
        isImporting = false
    }

    func confirmImport(modelContext: ModelContext, accountName: String) {
        for imported in importedTransactions {
            let transaction = Transaction(
                amount: imported.amount,
                type: imported.type,
                category: imported.description,
                date: imported.date,
                accountName: accountName
            )
            transaction.note = imported.description
            modelContext.insert(transaction)
        }
        try? modelContext.save()
        importedTransactions = []
    }
}
