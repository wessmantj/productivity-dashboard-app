import SwiftUI

struct StackStatCard: View {
    let value: String
    var unit: String = ""
    let label: String
    var icon: String = ""
    var iconColor: Color = StackTheme.Accent.primary
    var trend: String? = nil
    var isEmpty: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            StackCard {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                    // Icon top-left
                    if !icon.isEmpty {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(StackTheme.Accent.primary)
                    }

                    // Value + unit
                    if isEmpty {
                        Text("—")
                            .font(StackTheme.Typography.stat)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text(value)
                                .font(StackTheme.Typography.stat)
                                .foregroundStyle(StackTheme.Text.primary)
                            if !unit.isEmpty {
                                Text(unit)
                                    .font(StackTheme.Typography.subheadline)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    }

                    // Label + trend
                    HStack(spacing: StackTheme.Spacing.xs) {
                        Text(label.uppercased())
                            .font(StackTheme.Typography.label)
                            .foregroundStyle(StackTheme.Text.secondary)
                        if let trend {
                            Spacer()
                            Text(trend)
                                .font(StackTheme.Typography.label)
                                .foregroundStyle(
                                    trend.hasPrefix("+")
                                        ? StackTheme.Accent.positive
                                        : StackTheme.Accent.negative
                                )
                        }
                    }
                }
            }
            .frame(minHeight: 90, alignment: .leading)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
