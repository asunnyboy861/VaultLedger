import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showAddAccount = false
    @State private var showBackupExporter = false
    @State private var showBackupImporter = false
    @State private var newAccountName = ""
    @State private var newAccountType: Account.AccountType = .checking
    @State private var newAccountBalance = ""

    var body: some View {
        Form {
            accountsSection
            securitySection
            dataSection
            legalSection
            aboutSection
        }
        .navigationTitle("Settings")
        .onAppear {
            viewModel.loadAccounts(modelContext: modelContext)
        }
        .alert("Add Account", isPresented: $showAddAccount) {
            TextField("Account Name", text: $newAccountName)
            TextField("Balance", text: $newAccountBalance)
                .keyboardType(.decimalPad)
            Button("Add") {
                if let balance = Double(newAccountBalance) {
                    viewModel.addAccount(name: newAccountName, type: newAccountType, balance: balance, modelContext: modelContext)
                    newAccountName = ""
                    newAccountBalance = ""
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter account details")
        }
        .fileExporter(isPresented: $showBackupExporter, document: BackupDocument(data: viewModel.createBackup(modelContext: modelContext)), contentType: .json, defaultFilename: "VaultLedger_Backup") { _ in }
        .fileImporter(isPresented: $showBackupImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            handleBackupImport(result)
        }
    }

    private var accountsSection: some View {
        Section("Accounts") {
            ForEach(viewModel.accounts) { account in
                AccountRow(account: account)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteAccount(account, modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            Button("Add Account") {
                showAddAccount = true
            }
        }
    }

    private var securitySection: some View {
        Section("Security") {
            Toggle("Biometric Lock", isOn: Binding(
                get: { viewModel.isBiometricEnabled },
                set: { viewModel.toggleBiometric($0) }
            ))
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button {
                exportCSV()
            } label: {
                Label("Export CSV", systemImage: "square.and.arrow.up")
            }
            Button {
                showBackupExporter = true
            } label: {
                Label("Backup Data", systemImage: "externaldrive")
            }
            Button {
                showBackupImporter = true
            } label: {
                Label("Restore Backup", systemImage: "arrow.uturn.backward")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: Constants.supportPageURL)!) {
                Label("Support", systemImage: "questionmark.circle")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Build")
                Spacer()
                Text("2025.1")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func exportCSV() {
        if let data = viewModel.exportData(modelContext: modelContext) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("VaultLedger_Export.csv")
            try? data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }

    private func handleBackupImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                let manager = BackupManager()
                _ = manager.restoreBackup(data: data, modelContext: modelContext)
                viewModel.loadAccounts(modelContext: modelContext)
            }
        case .failure: break
        }
    }
}

struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack {
            Image(systemName: account.icon)
                .foregroundStyle(Color(hex: account.colorHex))
            VStack(alignment: .leading) {
                Text(account.name)
                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(NumberFormatter.currencyString(account.balance))
                .foregroundStyle(account.balance >= 0 ? Color.emeraldGreen : Color.coralRed)
        }
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data?

    init(data: Data?) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data else {
            throw NSError(domain: "BackupDocument", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data"])
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
