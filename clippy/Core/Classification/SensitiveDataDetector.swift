import Foundation

// MARK: - Detects potentially sensitive data (passwords, keys, secrets) in clipboard content

/// The specific kinds of sensitive content `SensitiveDataDetector` can
/// recognize. Split out (rather than one blanket "is this sensitive"
/// boolean) so `PrivacyPreferences` can gate persistence per-category —
/// e.g. block API keys but still keep OTPs.
enum SensitiveDataCategory: String, CaseIterable {
    case password
    case otp
    case apiKey
}

enum SensitiveDataDetector {
    /// Literal token prefixes issued by common providers — always API keys.
    private static let apiKeyLiteralPrefixes = [
        "sk_live_", "sk_test_", "pk_live_", "rk_live_",
        "ghp_", "gho_", "ghu_", "ghs_", "ghr_",
        "AKIA", "ASIA"
    ]

    // password=..., passwd: "..."
    private static let passwordPattern = try! NSRegularExpression(
        pattern: #"(?i)\b(password|passwd|pwd)\s*[:=]\s*\S+"#
    )

    private static let apiKeyPatterns: [NSRegularExpression] = [
        // api_key: "...", secret=..., access_token=...
        try! NSRegularExpression(
            pattern: #"(?i)\b(api[_-]?key|access[_-]?token|secret)\s*[:=]\s*\S+"#
        ),
        // Authorization: Bearer <token>
        try! NSRegularExpression(pattern: #"(?i)\bBearer\s+[A-Za-z0-9\-._~+/]+=*"#),
        // PEM private key header
        try! NSRegularExpression(pattern: #"-----BEGIN [A-Z ]*PRIVATE KEY-----"#),
        // JWT shape: header.payload.signature, base64url segments
        try! NSRegularExpression(pattern: #"\bey[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b"#)
    ]

    // "Your verification code is 123456", "OTP: 482910", "G-123456 is your code"
    private static let otpPattern = try! NSRegularExpression(
        pattern: #"(?i)\b(?:otp|one[- ]?time (?:code|password|passcode)|verification code|security code|passcode|auth(?:entication)? code)\b[^\d]{0,20}(\d{4,8})\b"#
    )

    /// All sensitive-data categories matched in `text`.
    static func categories(in text: String) -> Set<SensitiveDataCategory> {
        guard !text.isEmpty else { return [] }

        var found: Set<SensitiveDataCategory> = []
        let range = NSRange(location: 0, length: (text as NSString).length)

        if apiKeyLiteralPrefixes.contains(where: { text.contains($0) })
            || apiKeyPatterns.contains(where: { $0.firstMatch(in: text, options: [], range: range) != nil }) {
            found.insert(.apiKey)
        }
        if passwordPattern.firstMatch(in: text, options: [], range: range) != nil {
            found.insert(.password)
        }
        if otpPattern.firstMatch(in: text, options: [], range: range) != nil {
            found.insert(.otp)
        }

        return found
    }

    /// Returns true if the text contains any recognizable secret/credential shape.
    static func isSensitive(_ text: String) -> Bool {
        !categories(in: text).isEmpty
    }
}
