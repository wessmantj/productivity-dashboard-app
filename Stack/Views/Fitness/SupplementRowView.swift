import SwiftUI

struct SupplementRowView: View {
    let supplement: Supplement
    let onToggle: () -> Void
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundStyle(StackTheme.Accent.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(supplement.name)
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.primary)
                Text("\(supplement.dose) · \(supplement.time)")
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Text.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { supplement.isTakenToday },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(StackTheme.Accent.primary)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                }
                .buttonStyle(.plain)
                .padding(.leading, StackTheme.Spacing.xs)
            }
        }
        .padding(.vertical, 4)
    }
}
