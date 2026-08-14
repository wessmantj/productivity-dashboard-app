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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(iconColor)
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
                                .monospacedDigit()
                            if !unit.isEmpty {
                                Text(unit)
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    }

                    // Label + trend
                    HStack(spacing: StackTheme.Spacing.xs) {
                        StackLabel(label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if let trend {
                            Spacer()
                            Text(trend)
                                .font(StackTheme.Typography.label)
                                .monospacedDigit()
                                .foregroundStyle(
                                    trend.hasPrefix("+")
                                        ? StackTheme.Accent.positive
                                        : StackTheme.Accent.negative
                                )
                        }
                    }
                }
            }
            .frame(minHeight: 96, alignment: .leading)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
