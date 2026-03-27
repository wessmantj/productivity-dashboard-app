import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: StackTheme.Spacing.md) {
            Button(action: onToggle) {
                ZStack {
                    if exercise.isCompleted {
                        Circle()
                            .fill(StackTheme.Accent.primary)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .strokeBorder(StackTheme.Border.default, lineWidth: 1.5)
                            .frame(width: 26, height: 26)
                    }
                }
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(exercise.isCompleted ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                    .strikethrough(exercise.isCompleted, color: StackTheme.Text.tertiary)

                HStack(spacing: 6) {
                    Text("\(exercise.sets) sets · \(exercise.reps) reps")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                    if !exercise.weight.isEmpty {
                        Text("·")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                        Text(exercise.weight)
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .animation(.spring(duration: 0.25), value: exercise.isCompleted)
    }
}
