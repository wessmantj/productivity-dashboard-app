import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel    = TasksViewModel()
    @State private var newTask      = ""
    @State private var showCompleted = false
    @State private var taskToDelete: TaskItem?
    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.sm) {
                    // Inline add row
                    StackCard {
                        HStack(spacing: StackTheme.Spacing.sm) {
                            TextField("Add a task...", text: $newTask)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                                .focused($fieldFocused)
                                .onSubmit { addTask() }
                            Button("Add") { addTask() }
                                .font(StackTheme.Typography.body.bold())
                                .foregroundStyle(
                                    newTask.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? StackTheme.Accent.primary.opacity(0.35)
                                        : StackTheme.Accent.primary
                                )
                                .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
                                .buttonStyle(.plain)
                        }
                    }

                    if viewModel.activeTasks.isEmpty && viewModel.completedTasks.isEmpty {
                        ContentUnavailableView(
                            "No tasks yet",
                            systemImage: "checkmark.circle",
                            description: Text("Type above to add your first task.")
                        )
                        .foregroundStyle(StackTheme.Text.secondary)
                        .padding(.top, StackTheme.Spacing.xl)
                    } else {
                        // Active tasks
                        ForEach(viewModel.activeTasks) { task in
                            taskRow(task)
                        }

                        // Completed section
                        if !viewModel.completedTasks.isEmpty {
                            StackSectionHeader(title: "COMPLETED")

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showCompleted.toggle()
                                }
                            } label: {
                                Text(showCompleted
                                     ? "Hide completed"
                                     : "Show \(viewModel.completedTasks.count) completed")
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.tertiary)
                            }
                            .buttonStyle(.plain)

                            if showCompleted {
                                ForEach(viewModel.completedTasks) { task in
                                    taskRow(task)
                                }
                            }
                        }
                    }
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Tasks")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear { viewModel.setup(context: modelContext) }
        .alert("Delete task?", isPresented: Binding(
            get: { taskToDelete != nil },
            set: { if !$0 { taskToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let t = taskToDelete { viewModel.deleteTask(t) }
                taskToDelete = nil
            }
            Button("Cancel", role: .cancel) { taskToDelete = nil }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func addTask() {
        let trimmed = newTask.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.addTask(title: trimmed)
        newTask = ""
        fieldFocused = false
    }

    @ViewBuilder
    private func taskRow(_ task: TaskItem) -> some View {
        StackCard {
            HStack(spacing: StackTheme.Spacing.sm) {
                // Circular checkbox
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.toggleComplete(task)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(task.isComplete ? StackTheme.Accent.positive : Color.clear)
                            .frame(width: 24, height: 24)
                        Circle()
                            .stroke(
                                task.isComplete ? StackTheme.Accent.positive : StackTheme.Text.secondary,
                                lineWidth: 2
                            )
                            .frame(width: 24, height: 24)
                        if task.isComplete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .symbolEffect(.bounce, value: task.isComplete)
                }
                .buttonStyle(.plain)

                // Title — tapping also toggles
                Text(task.title)
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(task.isComplete ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                    .strikethrough(task.isComplete, color: StackTheme.Text.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleComplete(task)
                        }
                    }

                // Delete
                Button { taskToDelete = task } label: {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
