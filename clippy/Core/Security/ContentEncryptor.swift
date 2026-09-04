import Foundation
import CryptoKit
import Security

// MARK: - Secure content encryption/decryption using CryptoKit and Keychain

/// Provides 256-bit AES-GCM symmetric encryption for sensitive clipboard content.
/// The encryption key is stored securely in the macOS Keychain under the service
/// `com.clippy.clippy` and cached in-memory for fast repeated operations.
enum ContentEncryptor {
    private static let service = "com.clippy.clippy"
    private static let account = "com.clippy.content-encryption-key"

    private static let lock = NSLock()
    private static var cachedKey: SymmetricKey?

    /// Encrypts raw data using AES-GCM with the Keychain-backed symmetric key.
    /// Returns the combined nonce + ciphertext + tag representation.
    static func encrypt(_ data: Data) throws -> Data {
        let key = try obtainOrCreateKey()
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw ContentEncryptionError.encryptionFailed
            }
            return combined
        } catch let error as ContentEncryptionError {
            throw error
        } catch {
            throw ContentEncryptionError.encryptionFailed
        }
    }

    /// Decrypts AES-GCM sealed box combined data using the Keychain-backed symmetric key.
    static func decrypt(_ data: Data) throws -> Data {
        let key = try obtainOrCreateKey()
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw ContentEncryptionError.decryptionFailed
        }
    }

    /// Helper to encrypt a UTF-8 string.
    static func encrypt(string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw ContentEncryptionError.invalidData
        }
        return try encrypt(data)
    }

    /// Helper to decrypt data directly into a UTF-8 string.
    static func decryptToString(_ data: Data) throws -> String {
        let decryptedData = try decrypt(data)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw ContentEncryptionError.invalidData
        }
        return string
    }

    /// Returns whether an encryption key currently exists in Keychain or memory cache.
    static var hasKey: Bool {
        lock.lock()
        defer { lock.unlock() }
        if cachedKey != nil { return true }
        return (try? loadKeyFromKeychain()) != nil
    }

    /// Clears the in-memory key cache (forces re-reading from Keychain on next operation).
    static func resetCache() {
        lock.lock()
        cachedKey = nil
        lock.unlock()
    }

    // MARK: - Key Management

    private static func obtainOrCreateKey() throws -> SymmetricKey {
        lock.lock()
        defer { lock.unlock() }

        if let existing = cachedKey {
            return existing
        }

        if let loaded = try loadKeyFromKeychain() {
            cachedKey = loaded
            return loaded
        }

        let newKey = SymmetricKey(size: .bits256)
        try storeKeyInKeychain(newKey)
        cachedKey = newKey
        return newKey
    }

    private static func loadKeyFromKeychain() throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw ContentEncryptionError.invalidData
            }
            return SymmetricKey(data: data)
        case errSecItemNotFound:
            return nil
        default:
            throw ContentEncryptionError.keyRetrievalFailed(status)
        }
    }

    private static func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: keyData
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            if updateStatus != errSecSuccess {
                throw ContentEncryptionError.keyStorageFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw ContentEncryptionError.keyStorageFailed(status)
        }
    }
}

// MARK: - Errors

enum ContentEncryptionError: LocalizedError, Equatable {
    case keyRetrievalFailed(OSStatus)
    case keyStorageFailed(OSStatus)
    case encryptionFailed
    case decryptionFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .keyRetrievalFailed(let status):
            return "Failed to retrieve encryption key from Keychain (status: \(status))."
        case .keyStorageFailed(let status):
            return "Failed to save encryption key to Keychain (status: \(status))."
        case .encryptionFailed:
            return "Failed to encrypt clipboard content."
        case .decryptionFailed:
            return "Failed to decrypt sensitive content."
        case .invalidData:
            return "Invalid data encountered during encryption/decryption."
        }
    }
}
