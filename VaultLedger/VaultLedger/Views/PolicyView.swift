import SwiftUI

struct PolicyView: View {
    let policyType: PolicyType
    @State private var content: String = ""

    enum PolicyType {
        case privacy, support
    }

    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(policyType == .privacy ? "Privacy Policy" : "Support")
        .onAppear {
            loadContent()
        }
    }

    private func loadContent() {
        switch policyType {
        case .privacy:
            content = """
            Privacy Policy for VaultLedger

            Last updated: May 2025

            VaultLedger ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle your information.

            DATA COLLECTION
            VaultLedger is a 100% offline application. We do NOT collect, transmit, or store any personal data on external servers. All your financial data remains exclusively on your device.

            DATA STORAGE
            - All data is stored locally using iOS SwiftData
            - Sensitive data is encrypted using AES-256-GCM
            - Data never leaves your device unless you explicitly export it
            - No analytics, tracking, or telemetry

            BIOMETRIC AUTHENTICATION
            - Face ID / Touch ID is used solely for app lock
            - Biometric data never leaves the Secure Enclave
            - You can disable biometric lock in Settings

            DATA SHARING
            We do NOT share your data with any third parties, ever.

            DATA RETENTION
            Your data persists on your device until you delete the app or clear app data.

            CHILDREN'S PRIVACY
            VaultLedger is not directed at children under 13.

            CHANGES
            We may update this policy. Changes will be reflected in the "Last updated" date.

            CONTACT
            For questions: iocompile67692@gmail.com
            """
        case .support:
            content = """
            VaultLedger Support

            Thank you for using VaultLedger!

            GETTING STARTED
            1. Create your first account in Settings > Accounts
            2. Add transactions using the + button
            3. Import bank statements from CSV or PDF files
            4. Set budgets to track your spending
            5. View your net worth over time

            FEATURES
            - 100% Offline: Your data never leaves your device
            - Biometric Lock: Secure with Face ID / Touch ID
            - Bank Import: CSV and PDF statement support
            - Subscription Detection: Auto-find recurring charges
            - Budget Tracking: Set and monitor spending limits
            - Net Worth Tracking: Watch your wealth grow
            - Data Backup: Full backup and restore

            IMPORTING BANK STATEMENTS
            1. Go to the Import tab
            2. Select your bank preset
            3. Choose your CSV or PDF file
            4. Preview and confirm the import

            CONTACT US
            Email: iocompile67692@gmail.com
            We typically respond within 24-48 hours.

            FAQ
            Q: Is my data safe?
            A: Yes! All data is stored locally and encrypted with AES-256-GCM.

            Q: Can I sync between devices?
            A: Currently, VaultLedger is offline-only. You can backup and restore data manually.

            Q: How do I export my data?
            A: Go to Settings > Data > Export CSV
            """
        }
    }
}
