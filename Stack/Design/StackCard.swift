import SwiftUI

struct StackCard<Content: View>: View {
    // accent kept for call-site compatibility — no longer rendered
    var accent: Color? = nil
    var elevated: Bool = false
    var padding: CGFloat = StackTheme.Spacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(elevated
                ? StackTheme.Background.elevated
                : StackTheme.Background.surface)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
    }
}
