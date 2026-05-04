import SwiftUI
import SwiftData

struct SubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SubscriptionViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Estimated Monthly Cost")
                        .font(.subheadline)
                    Spacer()
                    Text(NumberFormatter.currencyString(viewModel.totalMonthlyCost))
                        .font(.headline)
                        .foregroundStyle(Color.coralRed)
                }
            }

            Section("Detected Subscriptions") {
                if viewModel.detectedSubscriptions.isEmpty {
                    ContentUnavailableView("No Subscriptions Detected", systemImage: "arrow.triangle.2.circlepath", description: Text("Subscriptions are auto-detected from recurring transactions"))
                } else {
                    ForEach(viewModel.detectedSubscriptions) { sub in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sub.merchant.capitalized)
                                    .font(.subheadline)
                                HStack(spacing: 4) {
                                    Text(sub.frequency.displayName)
                                    Text("·")
                                    Text("Next: \(sub.nextEstimatedDate.formattedShort)")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(NumberFormatter.currencyString(sub.amount))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.coralRed)
                                Text("\(Int(sub.confidence * 100))% confidence")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Subscriptions")
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
    }
}
