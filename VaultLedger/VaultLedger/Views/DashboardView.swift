import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                balanceCard
                incomeExpenseRow
                budgetSection
                subscriptionsSection
                recentTransactionsSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
        .refreshable {
            viewModel.loadData(modelContext: modelContext)
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(NumberFormatter.currencyString(viewModel.totalBalance))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.emeraldGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSeaBlue.gradient)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .foregroundStyle(.white)
    }

    private var incomeExpenseRow: some View {
        HStack(spacing: 12) {
            statCard(title: "Income", value: viewModel.monthlyIncome, color: .emeraldGreen, icon: "arrow.up.circle.fill")
            statCard(title: "Expenses", value: viewModel.monthlyExpenses, color: .coralRed, icon: "arrow.down.circle.fill")
        }
    }

    private func statCard(title: String, value: Double, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(NumberFormatter.currencyString(value))
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    private var budgetSection: some View {
        Group {
            if !viewModel.budgetProgress.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Progress")
                        .font(.headline)

                    ForEach(viewModel.budgetProgress) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.category)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(NumberFormatter.currencyString(item.spent)) / \(NumberFormatter.currencyString(item.limit))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: min(item.progress, 1.0))
                                .tint(item.progress > 1.0 ? .red : .emeraldGreen)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }

    private var subscriptionsSection: some View {
        Group {
            if !viewModel.detectedSubscriptions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Detected Subscriptions")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.detectedSubscriptions.count) found")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(Array(viewModel.detectedSubscriptions.prefix(3))) { sub in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(sub.merchant.capitalized)
                                    .font(.subheadline)
                                Text(sub.frequency.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(NumberFormatter.currencyString(sub.amount))
                                .font(.subheadline)
                                .foregroundStyle(Color.coralRed)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)

            if viewModel.recentTransactions.isEmpty {
                ContentUnavailableView("No Transactions", systemImage: "doc.text", description: Text("Add your first transaction"))
            } else {
                ForEach(viewModel.recentTransactions) { txn in
                    TransactionRowView(transaction: txn)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundStyle(transaction.type == .income ? Color.emeraldGreen : Color.coralRed)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.subheadline)
                Text(transaction.accountName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type == .income ? "+" : "-")\(NumberFormatter.currencyString(transaction.amount))")
                    .font(.subheadline)
                    .foregroundStyle(transaction.type == .income ? Color.emeraldGreen : Color.coralRed)
                Text(transaction.date.formattedShort)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
