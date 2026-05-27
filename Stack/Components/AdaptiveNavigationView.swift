import SwiftUI

struct AdaptiveNavigationView: View {

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        #if os(macOS)
        macOSNavigation
        #else
        iOSNavigation
        #endif
    }

    // MARK: - iOS (native TabView)

    @ViewBuilder
    private var iOSNavigation: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem { Label(AppTab.dashboard.label, systemImage: AppTab.dashboard.icon) }
                .tag(AppTab.dashboard)

            ProtocolView()
                .tabItem { Label(AppTab.proto.label, systemImage: AppTab.proto.icon) }
                .tag(AppTab.proto)

            FitnessView()
                .tabItem { Label(AppTab.fitness.label, systemImage: AppTab.fitness.icon) }
                .tag(AppTab.fitness)

            TasksView()
                .tabItem { Label(AppTab.tasks.label, systemImage: AppTab.tasks.icon) }
                .tag(AppTab.tasks)

            ProgressView()
                .tabItem { Label(AppTab.progress.label, systemImage: AppTab.progress.icon) }
                .tag(AppTab.progress)
        }
        .tint(StackTheme.Accent.primary)
        .stackTabBarStyle()
    }

    // MARK: - macOS (sidebar)

    #if os(macOS)
    @ViewBuilder
    private var macOSNavigation: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Label(AppTab.dashboard.label, systemImage: AppTab.dashboard.icon).tag(AppTab.dashboard)
                Label(AppTab.proto.label,     systemImage: AppTab.proto.icon).tag(AppTab.proto)
                Label(AppTab.fitness.label,   systemImage: AppTab.fitness.icon).tag(AppTab.fitness)
                Label(AppTab.tasks.label,     systemImage: AppTab.tasks.icon).tag(AppTab.tasks)
                Label(AppTab.progress.label,  systemImage: AppTab.progress.icon).tag(AppTab.progress)
            }
            .listStyle(.sidebar)
            .navigationTitle("Stack")
            .background(StackTheme.Background.base)
        } detail: {
            switch selectedTab {
            case .dashboard: DashboardView(selectedTab: $selectedTab)
            case .proto:     ProtocolView()
            case .fitness:   FitnessView()
            case .tasks:     TasksView()
            case .progress:  ProgressView()
            }
        }
    }
    #endif
}

#Preview {
    AdaptiveNavigationView()
}
