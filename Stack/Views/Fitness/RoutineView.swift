import SwiftUI
import SwiftData

struct RoutineView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutDay.dayOfWeek) private var workouts: [WorkoutDay]

    @State private var editingDay: WorkoutDay? = nil

    private static let dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    var body: some View {
        ScrollView {
            if workouts.isEmpty {
                emptyState
            } else {
                adaptiveGrid
            }
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(item: $editingDay) { day in
            EditWorkoutDaySheet(workout: day)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: StackTheme.Spacing.lg) {
            ContentUnavailableView(
                "No routine yet",
                systemImage: "dumbbell",
                description: Text("Build your weekly workout plan to get started.")
            )
            Button {
                seedWeek()
            } label: {
                Label("Build My Routine", systemImage: "plus.circle.fill")
                    .font(StackTheme.Typography.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(StackTheme.Accent.primary)
                    .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, StackTheme.Spacing.xl)
        }
        .padding(.top, 60)
    }

    // MARK: - Grid

    private var adaptiveGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 300), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(workouts) { workout in
                dayCard(workout)
                    .onTapGesture { editingDay = workout }
            }
        }
        .padding(StackTheme.Spacing.md)
    }

    @ViewBuilder
    private func dayCard(_ workout: WorkoutDay) -> some View {
        StackCard {
            HStack(spacing: StackTheme.Spacing.md) {
                // Day badge
                VStack(spacing: 2) {
                    Text(Self.dayNames[safe: workout.dayOfWeek] ?? "")
                        .font(StackTheme.Typography.label)
                        .foregroundStyle(workout.isRestDay ? StackTheme.Text.tertiary : StackTheme.Text.secondary)
                    Text("\(workout.dayOfWeek == 0 ? 7 : workout.dayOfWeek)")
                        .font(StackTheme.Typography.title)
                        .foregroundStyle(workout.isRestDay ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                }
                .frame(width: 44)

                VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                    if workout.isRestDay {
                        Text("Rest Day")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    } else {
                        Text(workout.muscleGroup.isEmpty ? "Tap to configure" : workout.muscleGroup)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(workout.muscleGroup.isEmpty ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                        Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                            .font(StackTheme.Typography.subheadline)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }

                Spacer()

                Image(systemName: workout.isRestDay ? "moon.zzz" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(StackTheme.Text.tertiary)
            }
        }
    }

    // MARK: - Seed 7 days

    private func seedWeek() {
        for day in 0..<7 {
            let workout = WorkoutDay(dayOfWeek: day)
            context.insert(workout)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
