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

                heroRingSection
                    .padding(.bottom, StackTheme.Spacing.xl)

                VStack(spacing: StackTheme.Spacing.sm) {
                    nowStrip
                    gaugeRow
                    activityRow
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
        }
        .onAppear { viewModel.setup(context: modelContext) }
        .task { await viewModel.loadHealthMetrics() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refresh()
                Task { await viewModel.loadHealthMetrics() }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                StackLabel(viewModel.formattedDate, tracking: StackTheme.Tracking.wide)

                Text(viewModel.userName.isEmpty
                     ? viewModel.greetingPrefix
                     : "\(viewModel.greetingPrefix), \(viewModel.userName)")
                    .font(StackTheme.Typography.title)
                    .foregroundStyle(StackTheme.Text.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            Spacer()

            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(StackTheme.Text.tertiary)
                    .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Hero ring (today's protocol)

    private var ringColor: Color {
        StackTheme.stateColor(for: viewModel.completionRatio)
    }

    private var heroRingSection: some View {
        Button {
            selectedTab = .proto
        } label: {
            VStack(spacing: StackTheme.Spacing.md) {
                StackRing(
                    value: viewModel.completionRatio,
                    color: ringColor,
                    lineWidth: 16,
                    size: 210
                ) {
                    VStack(spacing: 2) {
                        CountUpNumber(
                            value: Int(viewModel.completionRatio * 100),
                            suffix: "%",
                            color: ringColor
                        )
                        StackLabel("Protocol", tracking: StackTheme.Tracking.wide)
                    }
                }

                StackLabel(
                    "\(viewModel.completedBlocks) of \(viewModel.totalBlocks) blocks complete",
                    color: StackTheme.Text.tertiary
                )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CardPressStyle())
    }

    // MARK: - Right Now strip

    private var nowStrip: some View {
        Button {
            selectedTab = .proto
        } label: {
            StackCard {
                HStack(spacing: StackTheme.Spacing.md) {
                    PulsingDot(color: StackTheme.Accent.primary)

                    VStack(alignment: .leading, spacing: 3) {
                        StackLabel("Right now", color: StackTheme.Text.tertiary)
                        Text(viewModel.currentBlockTitle ?? "Free time")
                            .font(StackTheme.Typography.metric)
                            .foregroundStyle(StackTheme.Text.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Spacer()

                    if let time = viewModel.currentBlockTime {
                        Text(ScheduleTime.display(time))
                            .font(StackTheme.Typography.time)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
        }
        .buttonStyle(CardPressStyle())
    }

    // MARK: - Workout + Tasks gauges

    private var gaugeRow: some View {
        HStack(spacing: StackTheme.Spacing.sm) {
            workoutTile
            tasksTile
        }
        .frame(height: 136)
    }

    private var workoutTile: some View {
        Button {
            selectedTab = .fitness
        } label: {
            StackCard {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                    HStack {
                        StackLabel("Workout", color: StackTheme.Text.tertiary)
                        Spacer()
                        StackRing(
                            value: viewModel.workoutRatio,
                            color: viewModel.workoutRatio >= 1
                                ? StackTheme.Accent.positive
                                : StackTheme.Accent.primary,
                            lineWidth: 4,
                            size: 26,
                            glow: false
                        ) {
                            if viewModel.workoutRatio >= 1 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(StackTheme.Accent.positive)
                            }
                        }
                    }

                    Text(viewModel.todayWorkoutName)
                        .font(StackTheme.Typography.metric)
                        .foregroundStyle(StackTheme.Text.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)

                    Text(viewModel.todayWorkoutSubtitle.isEmpty ? " " : viewModel.todayWorkoutSubtitle)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .buttonStyle(CardPressStyle())
    }

    private var tasksTile: some View {
        Button {
            selectedTab = .tasks
        } label: {
            StackCard {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                    HStack {
                        StackLabel("Tasks", color: StackTheme.Text.tertiary)
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(StackTheme.Accent.primary)
                    }

                    CountUpNumber(
                        value: viewModel.openTaskCount,
                        font: StackTheme.Typography.stat
                    )

                    Spacer(minLength: 0)

                    Text("open")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .buttonStyle(CardPressStyle())
    }
}

// MARK: - Activity row (Fitbit → Apple Health)

extension DashboardView {

    private var activityRow: some View {
        HStack(spacing: StackTheme.Spacing.sm) {
            StackStatCard(
                value: viewModel.hkSteps.map { $0.formatted(.number.grouping(.automatic)) } ?? "—",
                label: "Steps",
                icon: "figure.walk",
                isEmpty: viewModel.hkSteps == nil
            )
            StackStatCard(
                value: viewModel.hkCalories.map(String.init) ?? "—",
                unit: "kcal",
                label: "Active",
                icon: "flame.fill",
                iconColor: StackTheme.Accent.warning,
                isEmpty: viewModel.hkCalories == nil
            )
            StackStatCard(
                value: viewModel.hkRestingHR.map(String.init) ?? "—",
                unit: "bpm",
                label: "Rest HR",
                icon: "heart.fill",
                iconColor: StackTheme.Accent.negative,
                isEmpty: viewModel.hkRestingHR == nil
            )
        }
    }
}

// MARK: - Pulsing live indicator

private struct PulsingDot: View {
    let color: Color
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 16, height: 16)
                .scaleEffect(pulsing ? 1.5 : 1.0)
                .opacity(pulsing ? 0 : 1)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}

// MARK: - Button style

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    AdaptiveNavigationView()
}
