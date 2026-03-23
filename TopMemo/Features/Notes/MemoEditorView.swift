import SwiftUI

struct MemoEditorView: View {
    @ObservedObject var viewModel: NotesViewModel
    let closePopover: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            header

            editorBody

            colorPalette
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.requestBack(closePopover: closePopover)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Spacer()

            Button("저장") {
                viewModel.saveCurrent()
            }
            .buttonStyle(.plain)
            .foregroundStyle(viewModel.canSave ? AppTheme.actionYellow : AppTheme.subduedText)
            .disabled(!viewModel.canSave)
        }
        .font(.system(size: 13, weight: .semibold))
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var editorBody: some View {
        MemoTextEditor(
            styledText: Binding(
                get: { viewModel.draft.styledText },
                set: { viewModel.updateStyledText($0) }
            ),
            activeColor: Binding(
                get: { viewModel.draft.activeColor },
                set: { viewModel.updateActiveColor($0) }
            ),
            colorSelectionRequest: viewModel.colorSelectionRequest,
            focusToken: viewModel.focusToken,
            onSave: {
                viewModel.saveCurrent()
            },
            onEscape: closePopover
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.elevatedBackground)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.subtleBorder, lineWidth: 1)
        }
    }

    private var colorPalette: some View {
        HStack(spacing: 12) {
            ForEach(MemoColor.allCases) { memoColor in
                Button {
                    viewModel.selectColor(memoColor)
                } label: {
                    ZStack {
                        Circle()
                            .fill(memoColor.color)
                            .frame(width: 22, height: 22)

                        if viewModel.draft.activeColor == memoColor {
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 4)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .help(memoColor.label)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}
