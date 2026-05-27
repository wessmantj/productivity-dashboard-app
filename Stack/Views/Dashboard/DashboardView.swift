import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase)   private var scenePhase

    @State private var viewModel   = DashboardViewModel()
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.bottom, StackTheme.Spacing.lg)

                VStack(spacing: StackTheme.Spacing.sm) {
                    rightNowSection
                    progressSection
                    workoutSection
                    tasksSection
                }
            }
            .padding(StackTheme.Spacing.md)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationBackground(StackTheme.Background.elevated)
                .presentationCornerRadius(StackTheme.Radius.lg)
                #if os(macOS)
                .frame(width: 480, height: 560)
                #endif
        }
        .onAppear { viewModel.setup(context: modelContext) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refresh() }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.greetingPrefix),")
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.secondary)

                if !viewModel.userName.isEmpty {
                    Text(viewModel.userName)
                        .font(StackTheme.Typography.hero)
                        .foregroundStyle(StackTheme.Text.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }

                Text(viewModel.formattedDate)
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .padding(.top, 2)
            }

            Spacer()

            Button { showSettings = true } label: {
                Image(systemName: "gear")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(StackTheme.Text.tertiary)
                    .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Right Now

    private var rightNowSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            StackSectionHeader("RIGHT NOW")
            Button {
                selectedTab = .proto
            } label: {
                StackCard {
                    if let title = viewModel.currentBlockTitle {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                            Text(title)
                                .font(StackTheme.Typography.metric)
                                .foregroundStyle(StackTheme.Text.primary)
                            if let time = viewModel.currentBlockTime {
                                Text(formattedTime(time))
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    } else {
                        Text("Free time")
                            .font(StackTheme.Typography.metric)
                            .foregroundStyle(StackTheme.Text.primary)
                    }
                }
            }
            .buttonStyle(CardPressStyle())
        }
    }

    // MARK: - Today's Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            StackSectionHeader("TODAY'S PROGRESS")
            Button {
                selectedTab = .proto
            } label: {
                StackCard {
                    VStack(spacing: StackTheme.Spacing.sm) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(viewModel.completedBlocks) of \(viewModel.totalBlocks) complete")
                                .font(StackTheme.Typography.metric)
                                .foregroundStyle(StackTheme.Text.primary)
                            Spacer()
                            Text("\(Int(viewModel.completionRatio * 100))%")
                                .font(StackTheme.Typography.metric)
                                .foregroundStyle(StackTheme.Accent.primary)
                                .contentTransition(.numericText())
                                .animation(.easeOut(duration: 0.4), value: viewModel.completionRatio)
                        }
                        StackProgressBar(
                            value: viewModel.completionRatio,
                            color: progressColor,
                            height: 6,
                            animated: true
                        )
                    }
                }
            }
            .buttonStyle(CardPressStyle())
        }
    }

    private var progressColor: Color {
        if viewModel.completionRatio > 0.8 { return StackTheme.Accent.positive }
        if viewModel.completionRatio > 0.4 { return StackTheme.Accent.warning }
        return StackTheme.Accent.negative
    }

    // MARK: - Today's Workout

    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            StackSectionHeader("TODAY'S WORKOUT")
            Button {
                selectedTab = .fitness
            } label: {
                StackCard {
                    VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                        Text(viewModel.todayWorkoutName)
                            .font(StackTheme.Typography.metric)
                            .foregroundStyle(StackTheme.Text.primary)
                        if !viewModel.todayWorkoutSubtitle.isEmpty {
                            Text(viewModel.todayWorkoutSubtitle)
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    }
                }
            }
            .buttonStyle(CardPressStyle())
        }
    }

    // MARK: - Tasks

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            StackSectionHeader("TASKS")
            StackStatCard(
                value: "\(viewModel.openTaskCount)",
                label: "open",
                icon: "checkmark.circle",
                iconColor: StackTheme.Accent.primary,
                action: { selectedTab = .tasks }
            )
        }
    }

    // MARK: - Helpers

    private func formattedTime(_ timeStr: String) -> String {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        let isPM = s.hasSuffix("pm")
        let isAM = s.hasSuffix("am")
        guard isPM || isAM else { return timeStr }
        let period = isPM ? "PM" : "AM"
        let clean = s
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return timeStr }
        let h = parts[0]
        let m = parts.count > 1 ? parts[1] : 0
        return String(format: "%d:%02d %@", h, m, period)
    }
}

// MARK: - Button style

private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    AdaptiveNavigationView()
}
