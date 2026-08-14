import SwiftUI
import SwiftData

struct EditWorkoutDaySheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let workout: WorkoutDay

    @State private var isRestDay: Bool
    @State private var muscleGroup: String
    @State private var showAddExercise = false
    @State private var newName = ""
    @State private var newSets = "3"
    @State private var newReps = "8-12"
    @State private var newWeight = ""

    init(workout: WorkoutDay) {
        self.workout = workout
        _isRestDay    = State(initialValue: workout.isRestDay)
        _muscleGroup  = State(initialValue: workout.muscleGroup)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Rest Day", isOn: $isRestDay)
                    if !isRestDay {
                        TextField("Muscle Group", text: $muscleGroup)
                    }
                } header: {
                    Text(Weekday.fullName(for: workout.dayOfWeek))
                }

                if !isRestDay {
                    Section("Exercises") {
                        let sorted = workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
                        ForEach(sorted) { exercise in
                            ExerciseEditRow(exercise: exercise)
                        }
                        .onDelete { indexSet in
                            let sorted2 = workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
                            for i in indexSet {
                                context.delete(sorted2[i])
                            }
                        }

                        Button {
                            showAddExercise = true
                        } label: {
                            Label("Add Exercise", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(StackTheme.Background.elevated)
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        workout.isRestDay   = isRestDay
                        workout.muscleGroup = isRestDay ? "Rest" : muscleGroup
                        dismiss()
                    }
                    .foregroundStyle(StackTheme.Accent.primary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }
            .sheet(isPresented: $showAddExercise) {
                addExerciseSheet
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
    }

    private var addExerciseSheet: some View {
        NavigationStack {
            Form {
                TextField("Exercise name", text: $newName)
                TextField("Sets", text: $newSets)
                    .keyboardType(.numberPad)
                TextField("Reps (e.g. 8-12)", text: $newReps)
                TextField("Weight (optional)", text: $newWeight)
            }
            .scrollContentBackground(.hidden)
            .background(StackTheme.Background.elevated)
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let order = workout.exercises.count
                        let ex = Exercise(
                            name: newName,
                            sets: Int(newSets) ?? 3,
                            reps: newReps.isEmpty ? "8-12" : newReps,
                            weight: newWeight,
                            sortOrder: order
                        )
                        context.insert(ex)
                        workout.exercises.append(ex)
                        newName = ""; newSets = "3"; newReps = "8-12"; newWeight = ""
                        showAddExercise = false
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .foregroundStyle(StackTheme.Accent.primary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddExercise = false }
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
    }
}

// Inline edit row inside the form
private struct ExerciseEditRow: View {
    let exercise: Exercise
    @State private var name: String
    @State private var sets: String
    @State private var reps: String
    @State private var weight: String

    init(exercise: Exercise) {
        self.exercise = exercise
        _name   = State(initialValue: exercise.name)
        _sets   = State(initialValue: "\(exercise.sets)")
        _reps   = State(initialValue: exercise.reps)
        _weight = State(initialValue: exercise.weight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Name", text: $name)
                .font(.body.weight(.medium))
                .onChange(of: name)   { exercise.name = name }
            HStack {
                TextField("Sets", text: $sets)
                    .keyboardType(.numberPad)
                    .onChange(of: sets)   { exercise.sets = Int(sets) ?? exercise.sets }
                Text("×")
                    .foregroundStyle(StackTheme.Text.secondary)
                TextField("Reps", text: $reps)
                    .onChange(of: reps)   { exercise.reps = reps }
                TextField("Weight", text: $weight)
                    .onChange(of: weight) { exercise.weight = weight }
            }
            .font(.caption)
            .foregroundStyle(StackTheme.Text.secondary)
        }
        .padding(.vertical, 2)
    }
}