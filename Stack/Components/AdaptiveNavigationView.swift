import SwiftUI

struct AdaptiveNavigationView: View {

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
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
}

#Preview {
    AdaptiveNavigationView()
}
