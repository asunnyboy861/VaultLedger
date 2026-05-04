import SwiftUI
import SwiftData
import LocalAuthentication

@main
struct VaultLedgerApp: App {
    @State private var biometricAuth = BiometricAuth()

    var body: some Scene {
        WindowGroup {
            Group {
                if biometricAuth.isAuthenticated || !biometricAuth.isBiometricAvailable {
                    ContentView()
                } else {
                    LockScreenView(biometricAuth: biometricAuth)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: biometricAuth.isAuthenticated)
        }
        .modelContainer(for: [Transaction.self, Account.self, Budget.self, NetWorthSnapshot.self])
    }
}

struct LockScreenView: View {
    @Bindable var biometricAuth: BiometricAuth

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.emeraldGreen)

            Text("VaultLedger")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your finances, secured offline")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    _ = await biometricAuth.authenticate()
                }
            } label: {
                Label("Unlock with \(biometricAuth.biometricType.displayName)", systemImage: biometricAuth.biometricType == .faceID ? "faceid" : "touchid")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.emeraldGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            if biometricAuth.isBiometricAvailable {
                Task {
                    _ = await biometricAuth.authenticate()
                }
            }
        }
    }
}
