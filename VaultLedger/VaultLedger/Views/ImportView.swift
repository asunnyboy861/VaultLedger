import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ImportViewModel()
    @State private var showCSVPicker = false
    @State private var showPDFPicker = false
    @State private var accountName = "Imported"

    var body: some View {
        Form {
            Section("Import Bank Statement") {
                Picker("Bank Preset", selection: $viewModel.selectedBank) {
                    ForEach(CSVImporter.BankPreset.allCases, id: \.self) { bank in
                        Text(bank.rawValue).tag(bank)
                    }
                }

                Button {
                    showCSVPicker = true
                } label: {
                    Label("Import CSV", systemImage: "doc.text")
                }

                Button {
                    showPDFPicker = true
                } label: {
                    Label("Import PDF", systemImage: "doc.richtext")
                }
            }

            if !viewModel.importedTransactions.isEmpty {
                Section("Preview (\(viewModel.importedTransactions.count) transactions)") {
                    TextField("Account Name", text: $accountName)

                    List {
                        ForEach(Array(viewModel.importedTransactions.enumerated()), id: \.offset) { index, txn in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(txn.description)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Text(txn.date.formattedShort)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(NumberFormatter.currencyString(txn.amount))
                                    .foregroundStyle(txn.type == .income ? Color.emeraldGreen : Color.coralRed)
                            }
                        }
                    }
                    .frame(height: 300)

                    Button("Confirm Import") {
                        viewModel.confirmImport(modelContext: modelContext, accountName: accountName)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Import")
        .fileImporter(isPresented: $showCSVPicker, allowedContentTypes: [.commaSeparatedText], allowsMultipleSelection: false) { result in
            handleCSVResult(result)
        }
        .fileImporter(isPresented: $showPDFPicker, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
            handlePDFResult(result)
        }
    }

    private func handleCSVResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                viewModel.processCSVData(data, modelContext: modelContext)
            }
        case .failure:
            viewModel.importError = "Failed to open file"
        }
    }

    private func handlePDFResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                viewModel.processPDFData(data, modelContext: modelContext)
            }
        case .failure:
            viewModel.importError = "Failed to open file"
        }
    }
}
