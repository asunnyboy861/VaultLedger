import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)

            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet.rectangle")
            }
            .tag(1)

            NavigationStack {
                ImportView()
            }
            .tabItem {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .tag(2)

            NavigationStack {
                NetWorthView()
            }
            .tabItem {
                Label("Net Worth", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(3)

            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
            }
            .tag(4)
        }
        .tint(Color.emeraldGreen)
    }
}

struct MoreView: View {
    var body: some View {
        List {
            NavigationLink(destination: BudgetView()) {
                Label("Budgets", systemImage: "chart.pie")
            }
            NavigationLink(destination: SubscriptionView()) {
                Label("Subscriptions", systemImage: "arrow.triangle.2.circlepath")
            }
            NavigationLink(destination: SettingsView()) {
                Label("Settings", systemImage: "gearshape")
            }
            NavigationLink(destination: ContactSupportView()) {
                Label("Contact Support", systemImage: "envelope")
            }
            NavigationLink(destination: PolicyView(policyType: .privacy)) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            NavigationLink(destination: PolicyView(policyType: .support)) {
                Label("Support", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("More")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Account.self, Budget.self, NetWorthSnapshot.self], inMemory: true)
}
