import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase)   private var scenePhase

    // Owned ViewModels — each set up from shared modelContext
    @State private var dashVM      = DashboardViewModel()
    @State private var protocolVM  = ProtocolViewModel()
    @State private var fitnessVM   = FitnessViewModel()
    @State private var healthVM    = HealthViewModel()
    @State private var learningVM  = LearningViewModel()
    @State private var visionVM    = VisionViewModel()
    @State private var tasksVM     = TasksViewModel()
    @State private var journalVM   = JournalViewModel()

    @State private var showSettings  = false
    @State private var showTasks     = false
    @State private var showJournal   = false

    // Layout
    #if os(macOS)
    private var isWide: Bool { true }
    #else
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isWide: Bool { sizeClass == .regular }
    #endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    content
                }
                .padding(StackTheme.Spacing.md)
                .frame(maxWidth: isWide ? 1100 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationBackground(StackTheme.Background.elevated)
                    .presentationCornerRadius(StackTheme.Radius.lg)
                    #if os(macOS)
                    .frame(width: 480, height: 560)
                    #endif
            }
            .sheet(isPresented: $showTasks) {
                TasksView()
                    .presentationBackground(StackTheme.Background.elevated)
                    .presentationCornerRadius(StackTheme.Radius.lg)
            }
            .sheet(isPresented: $showJournal) {
                JournalView()
                    .presentationBackground(StackTheme.Background.elevated)
                    .presentationCornerRadius(StackTheme.Radius.lg)
            }
        }
        .onAppear { refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
    }

    // MARK: — Master layout

    @ViewBuilder
    private var content: some View {
        // 1. Header
        headerCard

        // 2. Affirmation (full width)
        affirmationBanner

        // Cards: adaptive single / two-column
        if isWide {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: StackTheme.Spacing.sm),
                                GridItem(.flexible(), spacing: StackTheme.Spacing.sm)],
                      spacing: StackTheme.Spacing.sm) {
                workoutCard
                statsGroup
                learningCard
                journalCard
            }
        } else {
            VStack(spacing: StackTheme.Spacing.sm) {
                workoutCard
                statsRow
                learningCard
                journalCard
            }
        }

        // 6. Quote (full width)
        quoteCard

        // 9. Protocol pills (full width)
        protocolPills
    }

    // MARK: — 1. Header

    private var headerCard: some View {
        StackCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                    Text(dashVM.greeting)
                        .font(StackTheme.Typography.title)
                        .foregroundStyle(StackTheme.Text.primary)
                    Text(dashVM.dateString)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(dashVM.protocolRatio * 100))%")
                        .font(StackTheme.Typography.stat)
                        .foregroundStyle(StackTheme.Text.primary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.4), value: dashVM.protocolRatio)
                    Text("daily protocol")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }

            StackProgressBar(
                value: dashVM.protocolRatio,
                color: protocolColor,
                height: 6
            )
            .padding(.top, StackTheme.Spacing.sm)
        }
    }

    private var protocolColor: Color {
        let r = dashVM.protocolRatio
        if r > 0.8 { return StackTheme.Accent.positive }
        if r > 0.4 { return StackTheme.Accent.warning }
        return StackTheme.Accent.negative
    }

    // MARK: — 2. Affirmation

    private var affirmationBanner: some View {
        StackCard {
            Text(dashVM.dailyAffirmation?.text ?? "Stack up the days.")
                .font(StackTheme.Typography.quote)
                .foregroundStyle(StackTheme.Text.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: — 3. Workout card

    private var workoutCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                Label("Fitness", systemImage: "flame.fill")
                    .font(StackTheme.Typography.label)
                    .foregroundStyle(StackTheme.Text.secondary)

                if dashVM.todayIsRestDay {
                    Text("Rest Day")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Text.primary)
                    Text("Recover & Eat")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                } else if dashVM.todayMuscleGroup.isEmpty {
                    Text("No workout scheduled")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Text.secondary)
                } else {
                    Text(dashVM.todayMuscleGroup)
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Text.primary)

                    StackProgressBar(
                        value: dashVM.fitnessProgress,
                        color: StackTheme.Accent.primary,
                        height: 6
                    )

                    if dashVM.todayWorkoutComplete {
                        StackBadge(text: "COMPLETE", color: StackTheme.Accent.positive, style: .filled)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
        }
        .onTapGesture { selectedTab = .fitness }
    }

    // MARK: — 4. Stats (2×2 grid)

    // Used in single-column layout
    private var statsRow: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: StackTheme.Spacing.sm),
                             GridItem(.flexible(), spacing: StackTheme.Spacing.sm)],
                  spacing: StackTheme.Spacing.sm) {
            statCards
        }
    }

    // Used in wide layout as one grid cell containing the 2×2
    private var statsGroup: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: StackTheme.Spacing.sm),
                             GridItem(.flexible(), spacing: StackTheme.Spacing.sm)],
                  spacing: StackTheme.Spacing.sm) {
            statCards
        }
    }

    @ViewBuilder
    private var statCards: some View {
        // Sleep
        StackStatCard(
            value: dashVM.lastNightSleep != nil
                ? String(format: "%.1f", dashVM.lastNightSleep!)
                : "—",
            unit: dashVM.lastNightSleep != nil ? "hrs" : "",
            label: "Sleep",
            icon: "moon.zzz.fill",
            iconColor: StackTheme.Accent.primary,
            isEmpty: dashVM.lastNightSleep == nil,
            action: { selectedTab = .health }
        )

        // Weight
        StackStatCard(
            value: dashVM.currentWeight != nil
                ? String(format: "%.1f", dashVM.currentWeight!)
                : "—",
            unit: dashVM.currentWeight != nil ? "lbs" : "",
            label: "Weight",
            icon: "scalemass.fill",
            iconColor: StackTheme.Accent.primary,
            isEmpty: dashVM.currentWeight == nil,
            action: { selectedTab = .health }
        )

        // Tasks
        StackStatCard(
            value: "\(dashVM.todayTaskCount)",
            label: "Tasks remaining",
            icon: "checkmark.circle.fill",
            iconColor: StackTheme.Accent.primary,
            action: { showTasks = true }
        )

        // Streak
        StackStatCard(
            value: dashVM.journalStreak > 0 ? "\(dashVM.journalStreak)" : "—",
            unit: dashVM.journalStreak > 0 ? "days" : "",
            label: "Streak",
            icon: "flame.fill",
            iconColor: StackTheme.Accent.primary,
            isEmpty: dashVM.journalStreak == 0,
            action: { showJournal = true }
        )
    }

    // MARK: — 5. Learning card

    private var learningCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                Label("Learning", systemImage: "brain.head.profile")
                    .font(StackTheme.Typography.label)
                    .foregroundStyle(StackTheme.Text.secondary)

                Text(dashVM.currentPhaseName)
                    .font(StackTheme.Typography.headline)
                    .foregroundStyle(StackTheme.Text.primary)
                    .lineLimit(1)

                if !dashVM.currentWeekName.isEmpty {
                    Text(dashVM.currentWeekName)
                        .font(StackTheme.Typography.subheadline)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .lineLimit(1)
                }

                StackProgressBar(
                    value: dashVM.learningProgress,
                    color: StackTheme.Accent.primary,
                    height: 6
                )

                StackBadge(
                    text: "\(dashVM.completedLearningWeeks)/32 weeks",
                    color: StackTheme.Accent.primary,
                    style: .subtle
                )
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
        }
        .onTapGesture { selectedTab = .learn }
    }

    // MARK: — 7. Journal card

    private var journalCard: some View {
        StackCard {
            if dashVM.hasJournaledToday {
                HStack(spacing: StackTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                        Label("Journal", systemImage: "book.closed.fill")
                            .font(StackTheme.Typography.label)
                            .foregroundStyle(StackTheme.Text.secondary)
                        Text("Journal written today")
                            .font(StackTheme.Typography.headline)
                            .foregroundStyle(StackTheme.Text.primary)
                    }
                    Spacer()
                    StackBadge(text: "WRITTEN", color: StackTheme.Accent.positive, style: .filled)
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                        Label("Journal", systemImage: "book.closed.fill")
                            .font(StackTheme.Typography.label)
                            .foregroundStyle(StackTheme.Text.secondary)
                        Text("How was today?")
                            .font(StackTheme.Typography.callout)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                    Spacer()
                    Text("Write Now →")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
            }
        }
        .onTapGesture { showJournal = true }
    }

    // MARK: — 6. Quote card

    private var quoteCard: some View {
        StackCard(elevated: true, padding: StackTheme.Spacing.lg) {
            VStack(spacing: StackTheme.Spacing.sm) {
                if let q = dashVM.dailyQuote {
                    Text("\u{201C}\(q.text)\u{201D}")
                        .font(StackTheme.Typography.quote)
                        .foregroundStyle(StackTheme.Text.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                    Text("— \(q.author)")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                } else {
                    Text("\u{201C}We are what we repeatedly do. Excellence, then, is not an act, but a habit.\u{201D}")
                        .font(StackTheme.Typography.quote)
                        .foregroundStyle(StackTheme.Text.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                    Text("— Aristotle")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: — 8. Protocol pills

    private var protocolPills: some View {
        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "DAILY PROTOCOL", actionLabel: "View All") {
                selectedTab = .proto
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: StackTheme.Spacing.sm) {
                    ForEach(dashVM.sectionPills) { pill in
                        pillView(pill)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
        .onTapGesture { selectedTab = .proto }
    }

    private func pillView(_ pill: DashboardViewModel.SectionPill) -> some View {
        StackBadge(
            text: "\(pill.emoji) \(pill.completed)/\(pill.total)",
            color: pill.isComplete ? StackTheme.Accent.positive : StackTheme.Accent.primary,
            style: pill.isComplete ? .filled : .subtle
        )
    }

    // MARK: — Refresh

    private func refresh() {
        protocolVM.setup(context: modelContext)
        healthVM.setup(context: modelContext)
        learningVM.setup(context: modelContext)
        visionVM.setup(context: modelContext)
        tasksVM.setup(context: modelContext)
        journalVM.setup(context: modelContext)
        dashVM.setup(
            protocolVM: protocolVM,
            fitnessVM: fitnessVM,
            healthVM: healthVM,
            learningVM: learningVM,
            visionVM: visionVM,
            tasksVM: tasksVM,
            journalVM: journalVM,
            context: modelContext
        )
        Task { await healthVM.loadHealthKitData() }
    }
}
