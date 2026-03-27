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

            LearningView()
                .tabItem { Label(AppTab.learn.label, systemImage: AppTab.learn.icon) }
                .tag(AppTab.learn)

            // — More overflow —
            ProgressView()
                .tabItem { Label(AppTab.progress.label, systemImage: AppTab.progress.icon) }
                .tag(AppTab.progress)

            VisionView()
                .tabItem { Label(AppTab.vision.label, systemImage: AppTab.vision.icon) }
                .tag(AppTab.vision)

            HealthView()
                .tabItem { Label(AppTab.health.label, systemImage: AppTab.health.icon) }
                .tag(AppTab.health)
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
                Label(AppTab.learn.label,     systemImage: AppTab.learn.icon).tag(AppTab.learn)
                Label(AppTab.progress.label,  systemImage: AppTab.progress.icon).tag(AppTab.progress)
                Divider()
                Label(AppTab.vision.label,    systemImage: AppTab.vision.icon).tag(AppTab.vision)
                Label(AppTab.health.label,    systemImage: AppTab.health.icon).tag(AppTab.health)
            }
            .listStyle(.sidebar)
            .navigationTitle("Stack")
            .background(StackTheme.Background.base)
        } detail: {
            switch selectedTab {
            case .dashboard: DashboardView(selectedTab: $selectedTab)
            case .proto:     ProtocolView()
            case .fitness:   FitnessView()
            case .health:    HealthView()
            case .learn:     LearningView()
            case .progress:  ProgressView()
            case .vision:    VisionView()
            case .tasks:     TasksView()
            }
        }
    }
    #endif
}

#Preview {
    AdaptiveNavigationView()
}
