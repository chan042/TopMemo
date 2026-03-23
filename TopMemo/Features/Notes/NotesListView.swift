import AppKit
import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var copiedMemoID: UUID?
    @State private var isShowingCopyFeedback = false
    @State private var copyFeedbackToken = UUID()

    var body: some View {
        VStack(spacing: 12) {
            header

            if viewModel.notes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.notes) { memo in
                            MemoRowView(
                                memo: memo,
                                isCopied: copiedMemoID == memo.id,
                                onOpen: {
                                    viewModel.edit(memo)
                                },
                                onCopy: {
                                    copyMemo(memo)
                                }
                            )
                        }
                    }
                    .padding(.top, 2)
                }
                .scrollIndicators(.never)
            }

            addButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TopMemo")
                    .font(.system(size: 20, weight: .bold, design: .serif))

                Text("\(viewModel.notes.count)개의 메모")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText)
            }

            Spacer()

            Button {
                viewModel.openSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.subduedText)
            .help("설정")
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var emptyState: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.elevatedBackground)
            .overlay {
                Text("첫 메모를 작성해보세요.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.subtleBorder, lineWidth: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button {
            viewModel.startNewMemo()
        } label: {
            HStack(spacing: 8) {
                if !isShowingCopyFeedback {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                }

                Text(isShowingCopyFeedback ? "복사됨" : "새 메모")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.plusBackground)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: [.command])
    }

    private func copyMemo(_ memo: MemoItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(memo.content, forType: .string)

        let token = UUID()
        copyFeedbackToken = token

        withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
            copiedMemoID = memo.id
            isShowingCopyFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard copyFeedbackToken == token else {
                return
            }

            withAnimation(.easeInOut(duration: 0.18)) {
                copiedMemoID = nil
                isShowingCopyFeedback = false
            }
        }
    }
}

private struct MemoRowView: View {
    let memo: MemoItem
    let isCopied: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void

    private var previewColor: Color {
        memo.preferredColor == .black ? .primary : memo.preferredColor.color
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: onOpen) {
                Text(memo.previewText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(previewColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText.opacity(0.55))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
                    .scaleEffect(isCopied ? 1.32 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.45), value: isCopied)
            }
            .buttonStyle(.plain)
            .help("전체 메모 복사")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.memoRowCornerRadius)
                .fill(AppTheme.background.opacity(0.001))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.memoRowCornerRadius)
                .stroke(AppTheme.memoRowBorder, lineWidth: 1.2)
        }
    }
}
