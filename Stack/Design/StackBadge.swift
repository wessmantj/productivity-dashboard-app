import SwiftUI

struct StackBadge: View {
    // .outlined kept as alias for .subtle — call sites compile without changes
    enum Style { case filled, subtle, outlined }

    let text: String
    var color: Color = StackTheme.Accent.primary
    var style: Style = .subtle

    var body: some View {
        Text(text)
            .font(StackTheme.Typography.label)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .filled:             return .white
        case .subtle, .outlined:  return color
        }
    }

    private var background: Color {
        switch style {
        case .filled:             return color
        case .subtle, .outlined:  return StackTheme.Accent.soft
        }
    }
}
