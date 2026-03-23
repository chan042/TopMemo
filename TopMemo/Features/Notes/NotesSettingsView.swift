import SwiftUI

struct NotesSettingsView: View {
    @ObservedObject var viewModel: NotesViewModel

    var body: some View {
        VStack(spacing: 12) {
            header

            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.elevatedBackground)
                    .overlay {
                        VStack(spacing: 8) {
                            Text("설정")
                                .font(.system(size: 18, weight: .bold, design: .serif))

                            Text("여기에 설정 항목을 추가할 수 있습니다.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.subduedText)
                        }
                        .multilineTextAlignment(.center)
                        .padding(20)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.subtleBorder, lineWidth: 1)
                    }

                Button {
                    viewModel.requestDeleteAllMemos()
                } label: {
                    Text("모든 메모 지우기")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.12))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.24), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.hasNotes ? Color.red : AppTheme.subduedText)
                .disabled(!viewModel.hasNotes)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.closeSettings()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Text("설정")
                .font(.system(size: 16, weight: .bold, design: .serif))

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}
