import SwiftUI

struct StackBadge: View {
    enum Style { case filled, subtle }

    let text: String
    var color: Color = StackTheme.Accent.primary
    var style: Style = .subtle
    /// Text color when filled — black reads best on the bright state colors,
    /// white on indigo.
    var filledForeground: Color = .white

    var body: some View {
        Text(text.uppercased())
            .font(StackTheme.Typography.label)
            .tracking(StackTheme.Tracking.label)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        style == .subtle ? color.opacity(0.35) : .clear,
                        lineWidth: 1
                    )
            )
    }

    private var foreground: Color {
        switch style {
        case .filled: return filledForeground
        case .subtle: return color
        }
    }

    private var background: Color {
        switch style {
        case .filled: return color
        case .subtle: return color.opacity(0.12)
        }
    }
}
