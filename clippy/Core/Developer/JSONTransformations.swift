import Foundation

// MARK: - Pure functions for JSON detection and transformation

enum JSONTransformations {
    /// Returns true if `text` is a valid JSON object or array.
    static func isJSON(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
              (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) else {
            return false
        }
        guard let data = trimmed.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) != nil
    }

    /// Formats (pretty-prints) JSON with 2-space indentation.
    static func formatJSON(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
              ) else {
            return nil
        }
        return String(data: prettyData, encoding: .utf8)
    }

    /// Minifies JSON into a single compact line without extra whitespace.
    static func minifyJSON(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let compactData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            return nil
        }
        return String(data: compactData, encoding: .utf8)
    }

    /// Wraps the JSON string inside a markdown code block: ```json\n...\n```
    static func copyAsCodeBlock(_ text: String) -> String {
        let formatted = formatJSON(text) ?? text.trimmingCharacters(in: .whitespacesAndNewlines)
        return "```json\n\(formatted)\n```"
    }

    // MARK: - TypeScript Interface Generator

    /// Converts JSON text into TypeScript interface declarations.
    static func convertToTypeScriptInterface(_ text: String, rootName: String = "Root") -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return "// Invalid JSON"
        }

        var declarations: [String] = []

        if let dict = json as? [String: Any] {
            _ = generateTSInterface(name: rootName, dict: dict, declarations: &declarations)
        } else if let array = json as? [Any] {
            if let firstDict = array.compactMap({ $0 as? [String: Any] }).first {
                let itemName = "\(rootName)Item"
                _ = generateTSInterface(name: itemName, dict: firstDict, declarations: &declarations)
                declarations.append("export type \(rootName) = \(itemName)[];")
            } else {
                let elemType = array.first != nil ? inferPrimitiveType(array.first!) : "any"
                declarations.append("export type \(rootName) = \(elemType)[];")
            }
        }

        return declarations.reversed().joined(separator: "\n\n")
    }

    private static func generateTSInterface(
        name: String,
        dict: [String: Any],
        declarations: inout [String]
    ) -> String {
        var fields: [String] = []

        for key in dict.keys.sorted() {
            let value = dict[key]
            let fieldName = sanitizePropertyName(key)
            let typeString = inferTSType(key: key, value: value, declarations: &declarations)
            fields.append("  \(fieldName): \(typeString);")
        }

        let body = fields.joined(separator: "\n")
        let interfaceDecl = "export interface \(name) {\n\(body)\n}"
        declarations.append(interfaceDecl)
        return name
    }

    private static func inferTSType(
        key: String,
        value: Any?,
        declarations: inout [String]
    ) -> String {
        guard let value = value, !(value is NSNull) else {
            return "any"
        }

        if let dict = value as? [String: Any] {
            let subName = capitalizeFirst(key)
            return generateTSInterface(name: subName, dict: dict, declarations: &declarations)
        } else if let array = value as? [Any] {
            if array.isEmpty {
                return "any[]"
            }
            if let firstDict = array.compactMap({ $0 as? [String: Any] }).first {
                let subName = "\(capitalizeFirst(key))Item"
                _ = generateTSInterface(name: subName, dict: firstDict, declarations: &declarations)
                return "\(subName)[]"
            } else {
                let elemType = inferPrimitiveType(array[0])
                return "\(elemType)[]"
            }
        } else {
            return inferPrimitiveType(value)
        }
    }

    private static func inferPrimitiveType(_ value: Any) -> String {
        if value is Bool {
            return "boolean"
        } else if value is NSNumber {
            return "number"
        } else if value is String {
            return "string"
        } else {
            return "any"
        }
    }

    // MARK: - Zod Schema Generator

    /// Converts JSON text into a Zod validation schema.
    static func convertToZodSchema(_ text: String, rootName: String = "rootSchema") -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return "// Invalid JSON"
        }

        var declarations: [String] = []

        if let dict = json as? [String: Any] {
            _ = generateZodObject(name: rootName, dict: dict, declarations: &declarations)
        } else if let array = json as? [Any] {
            if let firstDict = array.compactMap({ $0 as? [String: Any] }).first {
                let itemName = "\(rootName)Item"
                _ = generateZodObject(name: itemName, dict: firstDict, declarations: &declarations)
                declarations.append("export const \(rootName) = z.array(\(itemName));")
            } else {
                let elemType = array.first != nil ? inferZodPrimitiveType(array.first!) : "z.any()"
                declarations.append("export const \(rootName) = z.array(\(elemType));")
            }
        }

        let typeName = capitalizeFirst(rootName.replacingOccurrences(of: "Schema", with: ""))
        let typeExport = "export type \(typeName) = z.infer<typeof \(rootName)>;"

        var result: [String] = ["import { z } from \"zod\";"]
        result.append(contentsOf: declarations.reversed())
        result.append(typeExport)
        return result.joined(separator: "\n\n")
    }

    private static func generateZodObject(
        name: String,
        dict: [String: Any],
        declarations: inout [String]
    ) -> String {
        var fields: [String] = []

        for key in dict.keys.sorted() {
            let value = dict[key]
            let fieldName = sanitizePropertyName(key)
            let schemaString = inferZodType(key: key, value: value, declarations: &declarations)
            fields.append("  \(fieldName): \(schemaString),")
        }

        let body = fields.joined(separator: "\n")
        let schemaDecl = "export const \(name) = z.object({\n\(body)\n});"
        declarations.append(schemaDecl)
        return name
    }

    private static func inferZodType(
        key: String,
        value: Any?,
        declarations: inout [String]
    ) -> String {
        guard let value = value, !(value is NSNull) else {
            return "z.any().nullable()"
        }

        if let dict = value as? [String: Any] {
            let subName = "\(key)Schema"
            return generateZodObject(name: subName, dict: dict, declarations: &declarations)
        } else if let array = value as? [Any] {
            if array.isEmpty {
                return "z.array(z.any())"
            }
            if let firstDict = array.compactMap({ $0 as? [String: Any] }).first {
                let subName = "\(key)ItemSchema"
                _ = generateZodObject(name: subName, dict: firstDict, declarations: &declarations)
                return "z.array(\(subName))"
            } else {
                let elemType = inferZodPrimitiveType(array[0])
                return "z.array(\(elemType))"
            }
        } else {
            return inferZodPrimitiveType(value)
        }
    }

    private static func inferZodPrimitiveType(_ value: Any) -> String {
        if value is Bool {
            return "z.boolean()"
        } else if value is NSNumber {
            return "z.number()"
        } else if value is String {
            return "z.string()"
        } else {
            return "z.any()"
        }
    }

    // MARK: - Helpers

    private static func sanitizePropertyName(_ name: String) -> String {
        let validIdentifier = name.range(of: "^[a-zA-Z_$][a-zA-Z0-9_$]*$", options: .regularExpression) != nil
        if validIdentifier {
            return name
        } else {
            return "\"\(name)\""
        }
    }

    private static func capitalizeFirst(_ string: String) -> String {
        guard let first = string.first else { return string }
        return String(first).uppercased() + string.dropFirst()
    }
}
