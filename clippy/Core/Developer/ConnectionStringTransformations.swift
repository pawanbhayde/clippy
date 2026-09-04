import Foundation

// MARK: - Pure functions for connection string detection and transformation

struct ConnectionDetails: Equatable {
    var raw: String
    var scheme: String
    var user: String?
    var password: String?
    var host: String?
    var port: Int?
    var database: String?
    var queryParams: [String: String]
}

enum ConnectionStringTransformations {
    private static let recognizedSchemes: Set<String> = [
        "postgresql", "postgres",
        "mysql", "mariadb",
        "mongodb", "mongodb+srv",
        "redis", "rediss"
    ]

    /// Checks if `text` is a recognized database connection string.
    static func isConnectionString(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let colonIndex = trimmed.range(of: "://")?.lowerBound else {
            return false
        }
        let scheme = String(trimmed[..<colonIndex]).lowercased()
        return recognizedSchemes.contains(scheme)
    }

    /// Parses a connection string into structured ConnectionDetails.
    static func parseConnectionString(_ text: String) -> ConnectionDetails? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isConnectionString(trimmed), let components = URLComponents(string: trimmed) else {
            return fallbackParse(trimmed)
        }

        let scheme = components.scheme?.lowercased() ?? ""
        var queryParams: [String: String] = [:]
        for item in components.queryItems ?? [] {
            queryParams[item.name] = item.value ?? ""
        }

        var database: String?
        if !components.path.isEmpty {
            let cleaned = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !cleaned.isEmpty {
                database = cleaned
            }
        }

        return ConnectionDetails(
            raw: trimmed,
            scheme: scheme,
            user: components.user,
            password: components.password,
            host: components.host,
            port: components.port ?? defaultPort(for: scheme),
            database: database,
            queryParams: queryParams
        )
    }

    /// Formats parsed connection details into human-readable key-value pairs.
    static func formatParsedConnection(_ text: String) -> String {
        guard let details = parseConnectionString(text) else {
            return text
        }

        var lines: [String] = []
        lines.append("Protocol:  \(details.scheme)")
        if let host = details.host {
            lines.append("Host:      \(host)")
        }
        if let port = details.port {
            lines.append("Port:      \(port)")
        }
        if let db = details.database {
            lines.append("Database:  \(db)")
        }
        if let user = details.user {
            lines.append("User:      \(user)")
        }
        if let password = details.password {
            lines.append("Password:  \(password)")
        }
        if !details.queryParams.isEmpty {
            let params = details.queryParams.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", ")
            lines.append("Params:    \(params)")
        }

        return lines.joined(separator: "\n")
    }

    /// Masks the password inside the connection string with dots.
    static func maskPassword(in text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isConnectionString(trimmed) else { return trimmed }

        // Regex to replace password between user: and @host
        // Pattern matches: (scheme://[^:]+:)([^@]+)(@.*)
        let pattern = #"^(https?:\/\/|[a-zA-Z0-9+_-]+:\/\/)([^:]+:)([^@]+)(@.+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return trimmed
        }

        let nsString = trimmed as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let masked = regex.stringByReplacingMatches(
            in: trimmed,
            options: [],
            range: range,
            withTemplate: "$1$2••••••••$4"
        )
        return masked
    }

    /// Generates standard environment variables (.env) from the connection string.
    static func generateDotEnv(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let details = parseConnectionString(trimmed) else {
            return "DATABASE_URL=\"\(trimmed)\""
        }

        var lines: [String] = []
        lines.append("DATABASE_URL=\"\(trimmed)\"")
        lines.append("DB_TYPE=\(details.scheme)")

        if let host = details.host {
            lines.append("DB_HOST=\(host)")
        }
        if let port = details.port {
            lines.append("DB_PORT=\(port)")
        }
        if let user = details.user {
            lines.append("DB_USER=\(user)")
        }
        if let password = details.password {
            lines.append("DB_PASSWORD=\(password)")
        }
        if let database = details.database {
            lines.append("DB_NAME=\(database)")
        }

        return lines.joined(separator: "\n")
    }

    /// Generates a Prisma-compatible connection URL string / env snippet.
    static func generatePrismaURL(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let details = parseConnectionString(trimmed) else {
            return "DATABASE_URL=\"\(trimmed)\""
        }

        var normalized = trimmed
        // For PostgreSQL / postgres schemas in Prisma, if no schema param is given, append ?schema=public
        if (details.scheme == "postgresql" || details.scheme == "postgres") {
            if details.queryParams["schema"] == nil {
                if normalized.contains("?") {
                    normalized += "&schema=public"
                } else {
                    normalized += "?schema=public"
                }
            }
        }

        return "DATABASE_URL=\"\(normalized)\""
    }

    private static func defaultPort(for scheme: String) -> Int? {
        switch scheme {
        case "postgresql", "postgres": return 5432
        case "mysql", "mariadb": return 3306
        case "mongodb": return 27017
        case "redis", "rediss": return 6379
        default: return nil
        }
    }

    private static func fallbackParse(_ text: String) -> ConnectionDetails? {
        // Fallback for URIs that might fail URLComponents parsing due to raw special characters
        guard let colonRange = text.range(of: "://") else { return nil }
        let scheme = String(text[..<colonRange.lowerBound]).lowercased()
        guard recognizedSchemes.contains(scheme) else { return nil }

        return ConnectionDetails(
            raw: text,
            scheme: scheme,
            user: nil,
            password: nil,
            host: nil,
            port: defaultPort(for: scheme),
            database: nil,
            queryParams: [:]
        )
    }
}
