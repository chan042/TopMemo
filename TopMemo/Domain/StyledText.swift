import Foundation

struct StyledTextRun: Codable, Equatable {
    var text: String
    var color: MemoColor
}

struct StyledText: Codable, Equatable {
    var runs: [StyledTextRun]

    init(runs: [StyledTextRun]) {
        self.runs = Self.normalize(runs)
    }

    init(text: String, color: MemoColor = .black) {
        self.init(
            runs: text.isEmpty ? [] : [StyledTextRun(text: text, color: color)]
        )
    }

    static let empty = StyledText(runs: [])

    var plainText: String {
        runs.map(\.text).joined()
    }

    var trimmedPlainText: String {
        plainText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var preferredColor: MemoColor {
        for run in runs {
            if !run.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return run.color
            }
        }

        return .black
    }

    private static func normalize(_ runs: [StyledTextRun]) -> [StyledTextRun] {
        var normalized: [StyledTextRun] = []

        for run in runs where !run.text.isEmpty {
            if let last = normalized.last, last.color == run.color {
                normalized[normalized.count - 1].text += run.text
            } else {
                normalized.append(run)
            }
        }

        return normalized
    }
}
