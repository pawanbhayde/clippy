import Foundation

// MARK: - Diff engine computing line-by-line comparison between two clipboard items

enum DiffLineType: Equatable {
    case unchanged
    case added
    case deleted
    case spacer
}

struct DiffLine: Identifiable, Equatable {
    let id = UUID()
    let type: DiffLineType
    let text: String
    let lineNumber: Int?
}

struct UnifiedDiffLine: Identifiable, Equatable {
    let id = UUID()
    let type: DiffLineType
    let text: String
    let oldLineNumber: Int?
    let newLineNumber: Int?
}

struct DiffResult: Equatable {
    let oldItem: ClipboardItem
    let newItem: ClipboardItem
    let additionsCount: Int
    let deletionsCount: Int
    let unifiedLines: [UnifiedDiffLine]
    let leftLines: [DiffLine]
    let rightLines: [DiffLine]
    let unifiedDiffString: String
}

enum DiffEngine {
    /// Compares two clipboard items and returns unified and side-by-side diff models.
    static func compare(oldItem: ClipboardItem, newItem: ClipboardItem) -> DiffResult {
        let oldText = MergerEngine.resolveText(for: oldItem)
        let newText = MergerEngine.resolveText(for: newItem)

        return compare(
            oldText: oldText,
            newText: newText,
            oldItem: oldItem,
            newItem: newItem
        )
    }

    /// Pure text comparison returning diff structures.
    static func compare(
        oldText: String,
        newText: String,
        oldItem: ClipboardItem,
        newItem: ClipboardItem
    ) -> DiffResult {
        let oldLines = oldText.isEmpty ? [] : oldText.components(separatedBy: "\n")
        let newLines = newText.isEmpty ? [] : newText.components(separatedBy: "\n")

        let m = oldLines.count
        let n = newLines.count

        // Standard Longest Common Subsequence (LCS) matrix
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0..<m {
            for j in 0..<n {
                if oldLines[i] == newLines[j] {
                    dp[i + 1][j + 1] = dp[i][j] + 1
                } else {
                    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1])
                }
            }
        }

        // Backtrack to reconstruct diff steps
        var i = m
        var j = n
        var rawSteps: [(type: DiffLineType, text: String, oldLine: Int?, newLine: Int?)] = []

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && oldLines[i - 1] == newLines[j - 1] {
                rawSteps.append((.unchanged, oldLines[i - 1], i, j))
                i -= 1
                j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                rawSteps.append((.added, newLines[j - 1], nil, j))
                j -= 1
            } else if i > 0 && (j == 0 || dp[i][j - 1] < dp[i - 1][j]) {
                rawSteps.append((.deleted, oldLines[i - 1], i, nil))
                i -= 1
            }
        }

        let orderedSteps = rawSteps.reversed()

        var unifiedLines: [UnifiedDiffLine] = []
        var additions = 0
        var deletions = 0

        for step in orderedSteps {
            unifiedLines.append(UnifiedDiffLine(
                type: step.type,
                text: step.text,
                oldLineNumber: step.oldLine,
                newLineNumber: step.newLine
            ))
            if step.type == .added { additions += 1 }
            if step.type == .deleted { deletions += 1 }
        }

        // Build Side-by-Side lines with synchronized spacer padding
        var leftLines: [DiffLine] = []
        var rightLines: [DiffLine] = []

        var stepIndex = 0
        let stepsArray = Array(orderedSteps)
        while stepIndex < stepsArray.count {
            let current = stepsArray[stepIndex]

            if current.type == .unchanged {
                leftLines.append(DiffLine(type: .unchanged, text: current.text, lineNumber: current.oldLine))
                rightLines.append(DiffLine(type: .unchanged, text: current.text, lineNumber: current.newLine))
                stepIndex += 1
            } else {
                // Collect contiguous block of changes
                var deletedBlock: [(text: String, line: Int?)] = []
                var addedBlock: [(text: String, line: Int?)] = []

                while stepIndex < stepsArray.count && stepsArray[stepIndex].type != .unchanged {
                    let s = stepsArray[stepIndex]
                    if s.type == .deleted {
                        deletedBlock.append((s.text, s.oldLine))
                    } else if s.type == .added {
                        addedBlock.append((s.text, s.newLine))
                    }
                    stepIndex += 1
                }

                let maxRows = max(deletedBlock.count, addedBlock.count)
                for r in 0..<maxRows {
                    if r < deletedBlock.count {
                        leftLines.append(DiffLine(type: .deleted, text: deletedBlock[r].text, lineNumber: deletedBlock[r].line))
                    } else {
                        leftLines.append(DiffLine(type: .spacer, text: "", lineNumber: nil))
                    }

                    if r < addedBlock.count {
                        rightLines.append(DiffLine(type: .added, text: addedBlock[r].text, lineNumber: addedBlock[r].line))
                    } else {
                        rightLines.append(DiffLine(type: .spacer, text: "", lineNumber: nil))
                    }
                }
            }
        }

        // Build unified patch format string
        var patch = [
            "--- Original (\(oldItem.sourceApp?.name ?? "Clippy"))",
            "+++ Modified (\(newItem.sourceApp?.name ?? "Clippy"))",
            "@@ -\(m > 0 ? "1,\(m)" : "0,0") +\(n > 0 ? "1,\(n)" : "0,0") @@"
        ]
        for line in unifiedLines {
            switch line.type {
            case .unchanged:
                patch.append("  \(line.text)")
            case .added:
                patch.append("+ \(line.text)")
            case .deleted:
                patch.append("- \(line.text)")
            case .spacer:
                break
            }
        }

        return DiffResult(
            oldItem: oldItem,
            newItem: newItem,
            additionsCount: additions,
            deletionsCount: deletions,
            unifiedLines: unifiedLines,
            leftLines: leftLines,
            rightLines: rightLines,
            unifiedDiffString: patch.joined(separator: "\n")
        )
    }
}
