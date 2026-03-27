import SwiftUI

// Applies native tab bar appearance — solid charcoal background, indigo selected state, no separator.
// Apply via .stackTabBarStyle() on the TabView in AdaptiveNavigationView.

#if os(iOS)
private struct StackTabBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear(perform: applyAppearance)
    }

    private func applyAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(StackTheme.Background.surface)
        appearance.shadowColor = .clear

        let item = UITabBarItemAppearance()
        item.normal.iconColor   = UIColor(StackTheme.Text.secondary)
        item.normal.titleTextAttributes  = [.foregroundColor: UIColor(StackTheme.Text.secondary)]
        item.selected.iconColor = UIColor(StackTheme.Accent.primary)
        item.selected.titleTextAttributes = [.foregroundColor: UIColor(StackTheme.Accent.primary)]

        appearance.stackedLayoutAppearance       = item
        appearance.inlineLayoutAppearance        = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension View {
    func stackTabBarStyle() -> some View {
        modifier(StackTabBarStyle())
    }
}
#else
extension View {
    func stackTabBarStyle() -> some View { self }
}
#endif
