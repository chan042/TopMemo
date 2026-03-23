import Foundation

struct MemoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var styledText: StyledText
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        styledText: StyledText,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.styledText = styledText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(
        id: UUID = UUID(),
        content: String,
        color: MemoColor = .black,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.init(
            id: id,
            styledText: StyledText(text: content, color: color),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var content: String {
        styledText.plainText
    }

    var preferredColor: MemoColor {
        styledText.preferredColor
    }

    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var previewText: String {
        let normalized = trimmedContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if normalized.isEmpty {
            return "빈 메모"
        }

        return String(normalized.prefix(120))
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case content
        case color
        case styledText
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)

        let legacyContent = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        let legacyColor = try container.decodeIfPresent(MemoColor.self, forKey: .color) ?? .black

        if let styledText = try container.decodeIfPresent(StyledText.self, forKey: .styledText),
           !styledText.runs.isEmpty || legacyContent.isEmpty {
            self.styledText = styledText
        } else {
            styledText = StyledText(text: legacyContent, color: legacyColor)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(preferredColor, forKey: .color)
        try container.encode(styledText, forKey: .styledText)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
