import Foundation
import Observation
import SwiftData

@Observable
final class TasksViewModel {

    private(set) var activeTasks:    [TaskItem] = []
    private(set) var completedTasks: [TaskItem] = []
    var errorMessage: String? = nil

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        loadAll()
    }

    private func loadAll() {
        guard let ctx = modelContext else { return }
        do {
            var aDesc = FetchDescriptor<TaskItem>()
            aDesc.predicate = #Predicate<TaskItem> { !$0.isComplete }
            activeTasks = try ctx.fetch(aDesc)

            var cDesc = FetchDescriptor<TaskItem>(
                sortBy: [SortDescriptor(\.completedDate, order: .reverse)]
            )
            cDesc.predicate = #Predicate<TaskItem> { $0.isComplete }
            completedTasks = try ctx.fetch(cDesc)
        } catch {}
    }

    // MARK: - CRUD

    func addTask(title: String) {
        guard let ctx = modelContext else { return }
        let task = TaskItem(title: title, sortOrder: activeTasks.count)
        ctx.insert(task)
        do { try ctx.save() } catch { errorMessage = error.localizedDescription; return }
        activeTasks.insert(task, at: 0)
    }

    func toggleComplete(_ task: TaskItem) {
        task.isComplete.toggle()
        if task.isComplete {
            task.completedDate = Date()
            activeTasks.removeAll { $0 === task }
            completedTasks.insert(task, at: 0)
        } else {
            task.completedDate = nil
            completedTasks.removeAll { $0 === task }
            activeTasks.append(task)
        }
        guard let ctx = modelContext else { return }
        do { try ctx.save() } catch { errorMessage = error.localizedDescription }
    }

    func deleteTask(_ task: TaskItem) {
        guard let ctx = modelContext else { return }
        ctx.delete(task)
        do { try ctx.save() } catch { errorMessage = error.localizedDescription; return }
        activeTasks.removeAll { $0 === task }
        completedTasks.removeAll { $0 === task }
    }
}
