import SwiftUI
import SwiftData

struct TodayWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Query private var allWorkouts: [WorkoutDay]
    @Query private var supplements: [Supplement]

    let viewModel: FitnessViewModel

    @State private var showCompletionBurst = false
    @State private var supplementToDelete: Supplement?

    private var todayWorkout: WorkoutDay? {
        allWorkouts.first { $0.dayOfWeek == viewModel.todayWeekday }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: StackTheme.Spacing.md) {
                if let workout = todayWorkout {
                    if workout.isRestDay {
                        restDayCard
                    } else {
                        workoutCard(workout)
                    }
                } else {
                    noRoutinePrompt
                }

                supplementsSection
                nutritionCard
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
    }

    // MARK: - Rest Day

    private var restDayCard: some View {
        StackCard(elevated: true) {
            VStack(spacing: StackTheme.Spacing.md) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(StackTheme.Accent.primary)
                Text("Rest Day")
                    .font(StackTheme.Typography.title)
                    .foregroundStyle(StackTheme.Text.primary)
                Text("Recovery is where the gains are made.\nEnjoy the rest.")
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(StackTheme.Spacing.md)
        }
    }

    // MARK: - No routine

    private var noRoutinePrompt: some View {
        ContentUnavailableView(
            "No routine yet",
            systemImage: "dumbbell",
            description: Text("Switch to the Routine tab to build your weekly plan.")
        )
        .padding(.top, StackTheme.Spacing.xl)
    }

    // MARK: - Workout card

    @ViewBuilder
    private func workoutCard(_ workout: WorkoutDay) -> some View {
        StackCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                        Text(workout.muscleGroup)
                            .font(StackTheme.Typography.title)
                            .foregroundStyle(StackTheme.Text.primary)
                        Text(todayLabel)
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                    Spacer()
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundStyle(StackTheme.Accent.primary)
                }
                .padding(StackTheme.Spacing.md)

                // Progress bar
                StackProgressBar(
                    value: viewModel.progress(for: workout),
                    color: workout.isCompleted ? StackTheme.Accent.positive : StackTheme.Accent.primary,
                    height: 6
                )
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.bottom, StackTheme.Spacing.md)

                // Exercises
                let sorted = workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, exercise in
                    if index > 0 {
                        Divider()
                            .overlay(StackTheme.Border.subtle)
                            .padding(.horizontal, StackTheme.Spacing.md)
                    }
                    ExerciseRowView(exercise: exercise) {
                        exercise.isCompleted.toggle()
                        autoCompleteIfNeeded(workout)
                    }
                    .padding(.horizontal, StackTheme.Spacing.md)
                }

                Divider()
                    .overlay(StackTheme.Border.subtle)
                    .padding(.vertical, StackTheme.Spacing.sm)

                // Complete button / completed state
                if workout.isCompleted {
                    completedBanner
                        .padding(.horizontal, StackTheme.Spacing.md)
                        .padding(.bottom, StackTheme.Spacing.md)
                } else {
                    completeButton(workout)
                        .padding(.horizontal, StackTheme.Spacing.md)
                        .padding(.bottom, StackTheme.Spacing.md)
                }
            }
        }
    }

    private var completedBanner: some View {
        HStack {
            Spacer()
            StackBadge(text: "WORKOUT COMPLETE", color: StackTheme.Accent.positive, style: .filled)
            Spacer()
        }
    }

    @ViewBuilder
    private func completeButton(_ workout: WorkoutDay) -> some View {
        Button {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                viewModel.completeWorkout(workout)
                showCompletionBurst = true
            }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
        } label: {
            Label("Complete Workout", systemImage: "flame.fill")
                .font(StackTheme.Typography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(StackTheme.Accent.primary)
                .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Supplements

    private var supplementsSection: some View {
        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "SUPPLEMENTS")

            StackCard {
                VStack(alignment: .leading, spacing: 0) {
                    if supplements.isEmpty {
                        Text("No supplements added yet.")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.secondary)
                    } else {
                        let sorted = supplements.sorted { $0.time < $1.time }
                        ForEach(Array(sorted.enumerated()), id: \.element.id) { index, supplement in
                            if index > 0 {
                                Divider()
                                    .overlay(StackTheme.Border.subtle)
                            }
                            SupplementRowView(supplement: supplement) {
                                supplement.isTakenToday.toggle()
                                supplement.lastResetDate = Date()
                            } onDelete: {
                                supplementToDelete = supplement
                            }
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.resetSupplementsIfNeeded(supplements) }
        .alert("Delete supplement?", isPresented: Binding(
            get: { supplementToDelete != nil },
            set: { if !$0 { supplementToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let s = supplementToDelete { context.delete(s) }
                supplementToDelete = nil
            }
            Button("Cancel", role: .cancel) { supplementToDelete = nil }
        }
    }

    // MARK: - Nutrition

    private var nutritionCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                Label("Nutrition", systemImage: "fork.knife")
                    .font(StackTheme.Typography.headline)
                    .foregroundStyle(StackTheme.Text.primary)

                HStack(spacing: StackTheme.Spacing.sm) {
                    ForEach(FitnessViewModel.NutritionStatus.allCases, id: \.self) { status in
                        let isSelected = viewModel.nutritionStatus == status
                        Button {
                            viewModel.nutritionStatus = status
                        } label: {
                            StackBadge(
                                text: status.label,
                                color: nutritionColor(for: status),
                                style: isSelected ? .filled : .subtle
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var todayLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMMM d"
        return fmt.string(from: Date())
    }

    private func autoCompleteIfNeeded(_ workout: WorkoutDay) {
        let allDone = workout.exercises.allSatisfy(\.isCompleted)
        if allDone && !workout.isCompleted {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                viewModel.completeWorkout(workout)
                showCompletionBurst = true
            }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
        }
    }

    private func nutritionColor(for status: FitnessViewModel.NutritionStatus) -> Color {
        switch status {
        case .onTrack:  return StackTheme.Accent.positive
        case .okay:     return StackTheme.Accent.warning
        case .offTrack: return StackTheme.Accent.negative
        }
    }
}
