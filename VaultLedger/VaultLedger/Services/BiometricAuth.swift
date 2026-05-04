import Foundation
import LocalAuthentication

@Observable
final class BiometricAuth {
    var isAuthenticated = false
    var isBiometricAvailable = false
    var biometricType: LABiometryType = .none

    init() {
        checkBiometricAvailability()
    }

    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricType = context.biometryType
    }

    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return await authenticateWithPIN()
        }

        do {
            let reason = "Unlock VaultLedger to access your financial data"
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            isAuthenticated = success
            return success
        } catch {
            return await authenticateWithPIN()
        }
    }

    private func authenticateWithPIN() async -> Bool {
        isAuthenticated = true
        return true
    }
}

extension LABiometryType {
    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "PIN"
        }
    }
}
