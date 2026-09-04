import Foundation
import CryptoKit

// MARK: - Computes content hashes to detect duplicate clipboard entries

enum ClipboardHasher {
    /// SHA256 hex digest of the given data.
    static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    /// Convenience for hashing UTF-8 text content.
    static func hash(_ text: String) -> String {
        hash(Data(text.utf8))
    }
}
