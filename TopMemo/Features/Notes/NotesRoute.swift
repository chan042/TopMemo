import Foundation

enum TopMemoRoute: Equatable {
    case emptyComposer
    case memoList
    case editor(memoID: UUID?)
    case settings
}
