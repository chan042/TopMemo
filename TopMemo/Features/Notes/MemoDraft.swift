import Foundation

struct MemoDraft: Equatable {
    var memoID: UUID?
    var styledText: StyledText
    var activeColor: MemoColor
    var createdAt: Date?

    static let empty = MemoDraft(
        memoID: nil,
        styledText: .empty,
        activeColor: .black,
        createdAt: nil
    )

    static func from(_ memo: MemoItem) -> MemoDraft {
        MemoDraft(
            memoID: memo.id,
            styledText: memo.styledText,
            activeColor: memo.preferredColor,
            createdAt: memo.createdAt
        )
    }

    var content: String {
        styledText.plainText
    }

    var trimmedContent: String {
        styledText.trimmedPlainText
    }
}
