import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddTransactionViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .font(.system(.title2, design: .rounded))
                }

                Section("Type") {
                    Picker("Type", selection: $viewModel.selectedType) {
                        ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.categories) { cat in
                                CategoryPill(
                                    category: cat,
                                    isSelected: viewModel.selectedCategory == cat.name
                                ) {
                                    viewModel.selectedCategory = cat.name
                                }
                            }
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    TextField("Note", text: $viewModel.note)

                    Toggle("Recurring", isOn: $viewModel.isRecurring)

                    if viewModel.isRecurring {
                        Picker("Period", selection: $viewModel.recurringPeriod) {
                            ForEach(Transaction.RecurringPeriod.allCases, id: \.self) { period in
                                Text(period.rawValue.capitalized).tag(period)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save(modelContext: modelContext) {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.amount.isEmpty || Double(viewModel.amount) == nil)
                }
            }
        }
    }
}

struct CategoryPill: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)
                Text(category.name)
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: category.colorHex).opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(hex: category.colorHex) : Color.secondary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .foregroundStyle(isSelected ? Color(hex: category.colorHex) : .secondary)
        }
        .buttonStyle(.plain)
    }
}
