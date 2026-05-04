import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionListViewModel()
    @State private var showAddSheet = false

    var body: some View {
        List {
            ForEach(viewModel.filteredTransactions) { txn in
                TransactionRowView(transaction: txn)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteTransaction(txn, modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search transactions")
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
        }
        .onAppear {
            viewModel.loadTransactions(modelContext: modelContext)
        }
    }
}
