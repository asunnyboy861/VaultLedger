import Foundation
import CryptoKit

struct DataEncryptor {
    static func encrypt(data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            return nil
        }
    }

    static func decrypt(data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            return nil
        }
    }

    static func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    static func deriveKey(from pin: String, salt: Data = Data()) -> SymmetricKey {
        let pinData = Data(pin.utf8)
        let inputKeyMaterial = SymmetricKey(data: pinData)
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKeyMaterial,
            salt: salt,
            info: Data("VaultLedger".utf8),
            outputByteCount: 32
        )
        return derivedKey
    }

    static func saveKey(_ key: SymmetricKey, identifier: String = "com.zzoutuo.VaultLedger.encryptionkey") {
        let data = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: identifier.data(using: .utf8)!,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadKey(identifier: String = "com.zzoutuo.VaultLedger.encryptionkey") -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: identifier.data(using: .utf8)!,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return SymmetricKey(data: data)
    }
}
