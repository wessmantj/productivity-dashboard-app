import Foundation
import Observation
import SwiftData

@Observable
final class LearningViewModel {

    private(set) var phases: [LearningPhase] = []
    private(set) var readingEntries: [ReadingEntry] = []

    let totalWeeks: Int = 32

    var completedWeeks: Int {
        phases.flatMap { $0.weeks }.filter { $0.isComplete }.count
    }

    var overallProgress: Double {
        guard totalWeeks > 0 else { return 0 }
        return Double(completedWeeks) / Double(totalWeeks)
    }

    var currentPhase: LearningPhase? {
        phases.first { $0.weeks.contains { !$0.isComplete } }
    }

    var currentWeek: LearningWeek? {
        currentPhase?.weeks.sorted { $0.order < $1.order }.first { !$0.isComplete }
    }

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        LearningSeedService.seedIfNeeded(context: context)
        loadAll()
    }

    private func loadAll() {
        guard let ctx = modelContext else { return }
        do {
            let phaseDesc = FetchDescriptor<LearningPhase>(
                sortBy: [SortDescriptor(\.order)]
            )
            phases = try ctx.fetch(phaseDesc)

            let readingDesc = FetchDescriptor<ReadingEntry>(
                sortBy: [SortDescriptor(\.startedDate, order: .reverse)]
            )
            readingEntries = try ctx.fetch(readingDesc)
        } catch {}
    }

    // MARK: - Hours

    func logHours(week: LearningWeek, theory: Double, implementation: Double, synthesis: Double) {
        week.theoryHours += theory
        week.implementationHours += implementation
        week.synthesisHours += synthesis
        if week.startedDate == nil { week.startedDate = Date() }
        if let ctx = modelContext {
            let key = todayDateKey()
            let existing = DayRecordService.record(for: key, in: ctx)
            DayRecordService.updateLearning(
                hours: existing.learningHours + theory + implementation + synthesis,
                for: key, in: ctx
            )
        }
    }

    private func todayDateKey() -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    // MARK: - Topics

    func markTopicComplete(_ topic: LearningTopic) {
        topic.isComplete.toggle()
        // Find parent week and auto-complete if all topics done
        for phase in phases {
            for week in phase.weeks {
                if week.topics.contains(where: { $0 === topic }) {
                    if week.allTopicsComplete && !week.isComplete {
                        markWeekComplete(week)
                    }
                    break
                }
            }
        }
    }

    // MARK: - Weeks

    func markWeekComplete(_ week: LearningWeek) {
        week.isComplete = true
        week.completedDate = Date()
        if week.startedDate == nil { week.startedDate = Date() }
    }

    func toggleWeekComplete(_ week: LearningWeek) {
        if week.isComplete {
            week.isComplete = false
            week.completedDate = nil
        } else {
            markWeekComplete(week)
        }
    }

    // MARK: - Reading

    func addBook(title: String, author: String, totalPages: Int, dailyGoal: Int) {
        guard let ctx = modelContext else { return }
        let entry = ReadingEntry(title: title, author: author, totalPages: totalPages,
                                 dailyGoalPages: dailyGoal)
        ctx.insert(entry)
        readingEntries.insert(entry, at: 0)
    }

    func updateProgress(entry: ReadingEntry, currentPage: Int) {
        entry.currentPage = min(currentPage, entry.totalPages)
    }

    func markBookComplete(_ entry: ReadingEntry) {
        entry.currentPage = entry.totalPages
        entry.completedDate = Date()
    }

    func deleteBook(_ entry: ReadingEntry) {
        guard let ctx = modelContext else { return }
        ctx.delete(entry)
        readingEntries.removeAll { $0.id == entry.id }
    }
}
