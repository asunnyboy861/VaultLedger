import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BudgetViewModel()

    var body: some View {
        Form {
            Section("Add Budget") {
                TextField("Category", text: $viewModel.newCategory)
                TextField("Limit Amount", text: $viewModel.newLimitAmount)
                    .keyboardType(.decimalPad)
                Picker("Period", selection: $viewModel.newPeriod) {
                    ForEach(Budget.BudgetPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue.capitalized).tag(period)
                    }
                }
                Button("Add Budget") {
                    _ = viewModel.addBudget(modelContext: modelContext)
                }
                .disabled(viewModel.newCategory.isEmpty || Double(viewModel.newLimitAmount) == nil)
            }

            Section("Current Budgets") {
                if viewModel.budgets.isEmpty {
                    ContentUnavailableView("No Budgets", systemImage: "chart.pie", description: Text("Set your first budget limit"))
                } else {
                    ForEach(viewModel.budgets) { budget in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(budget.category)
                                    .font(.subheadline)
                                Text(budget.period.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(NumberFormatter.currencyString(budget.limitAmount))
                                .font(.subheadline)
                                .foregroundStyle(Color.emeraldGreen)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteBudget(budget, modelContext: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Budgets")
        .onAppear {
            viewModel.loadBudgets(modelContext: modelContext)
        }
    }
}

extension Budget.BudgetPeriod {
    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}
