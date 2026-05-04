import SwiftUI
import SwiftData
import Charts

struct NetWorthView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = NetWorthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                netWorthCard
                assetsLiabilitiesRow
                chartSection
            }
            .padding()
        }
        .navigationTitle("Net Worth")
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
    }

    private var netWorthCard: some View {
        VStack(spacing: 8) {
            Text("Net Worth")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(NumberFormatter.currencyString(viewModel.currentNetWorth))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.currentNetWorth >= 0 ? Color.emeraldGreen : Color.coralRed)
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

    private var assetsLiabilitiesRow: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Assets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(NumberFormatter.currencyString(viewModel.totalAssets))
                    .font(.headline)
                    .foregroundStyle(Color.emeraldGreen)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))

            VStack(spacing: 4) {
                Text("Liabilities")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(NumberFormatter.currencyString(viewModel.totalLiabilities))
                    .font(.headline)
                    .foregroundStyle(Color.coralRed)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        }
    }

    private var chartSection: some View {
        Group {
            if viewModel.snapshots.count >= 2 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Net Worth Over Time")
                        .font(.headline)

                    Chart(viewModel.snapshots.reversed()) { snapshot in
                        LineMark(
                            x: .value("Date", snapshot.date),
                            y: .value("Net Worth", snapshot.netWorth)
                        )
                        .foregroundStyle(Color.emeraldGreen)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", snapshot.date),
                            y: .value("Net Worth", snapshot.netWorth)
                        )
                        .foregroundStyle(Color.emeraldGreen.opacity(0.1))
                        .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text(NumberFormatter.currencyString(val))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            } else {
                ContentUnavailableView("Not Enough Data", systemImage: "chart.line.uptrend.xyaxis", description: Text("Net worth chart appears after 2+ days of tracking"))
                    .padding()
            }
        }
    }
}
