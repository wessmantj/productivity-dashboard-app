import SwiftUI

struct ProtocolItemRow: View {
    let item: ProtocolItem
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isCompleted ? StackTheme.Accent.primary : Color.clear)
                    .frame(width: 18, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isCompleted ? StackTheme.Accent.primary : StackTheme.Border.default,
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(isCompleted ? 1 : 0)
                    )
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            Text(item.text)
                .font(StackTheme.Typography.body)
                .foregroundStyle(isCompleted ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                .strikethrough(isCompleted, color: StackTheme.Text.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
        .animation(.spring(duration: 0.25), value: isCompleted)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
    }
}
