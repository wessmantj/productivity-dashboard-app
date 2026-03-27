import Foundation
import Observation
import SwiftData

@Observable
final class DashboardViewModel {

    // MARK: - Protocol
    var protocolRatio: Double = 0
    var protocolCompleted: Int = 0
    var protocolTotal: Int = 46

    // MARK: - Fitness
    var todayMuscleGroup: String = ""
    var todayWorkoutComplete: Bool = false
    var todayIsRestDay: Bool = false
    var fitnessProgress: Double = 0

    // MARK: - Health
    var currentWeight: Double? = nil
    var lastNightSleep: Double? = nil
    var sleepQuality: Int? = nil

    // MARK: - Learning
    var currentPhaseName: String = ""
    var currentWeekName: String = ""
    var learningProgress: Double = 0
    var completedLearningWeeks: Int = 0

    // MARK: - Vision
    var dailyQuote: Quote? = nil
    var dailyAffirmation: Affirmation? = nil

    // MARK: - Tasks
    var todayTaskCount: Int = 0
    var overdueCount: Int = 0
    var highPriorityCount: Int = 0

    // MARK: - Journal
    var journalStreak: Int = 0
    var hasJournaledToday: Bool = false

    // MARK: - Header
    var greeting: String = ""
    var dateString: String = ""

    // MARK: - Protocol section pills
    struct SectionPill: Identifiable {
        let id: String
        let emoji: String
        let label: String
        let completed: Int
        let total: Int
        var isComplete: Bool { completed == total && total > 0 }
    }
    var sectionPills: [SectionPill] = []

    // MARK: - Setup

    func setup(
        protocolVM: ProtocolViewModel,
        fitnessVM: FitnessViewModel,
        healthVM: HealthViewModel,
        learningVM: LearningViewModel,
        visionVM: VisionViewModel,
        tasksVM: TasksViewModel,
        journalVM: JournalViewModel,
        context: ModelContext
    ) {
        // Greeting & date
        let hour = Calendar.current.component(.hour, from: Date())
        let base = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        greeting = name.isEmpty ? base : "\(base), \(name)"
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMMM d"
        dateString = fmt.string(from: Date())

        // Protocol — fetch sections for ratio and pills
        do {
            let sections = try context.fetch(
                FetchDescriptor<ProtocolSection>(sortBy: [SortDescriptor(\.sortOrder)])
            )
            var totalItems = 0
            var completedItemCount = 0
            var pills: [SectionPill] = []
            for section in sections {
                let items = section.items.sorted { $0.sortOrder < $1.sortOrder }
                let sectionDone = items.filter { protocolVM.completedItems.contains($0.id) }.count
                totalItems += items.count
                completedItemCount += sectionDone
                pills.append(SectionPill(
                    id: section.id, emoji: section.emoji, label: section.label,
                    completed: sectionDone, total: items.count
                ))
            }
            protocolTotal = max(totalItems, 46)
            protocolCompleted = completedItemCount
            protocolRatio = protocolTotal > 0 ? Double(protocolCompleted) / Double(protocolTotal) : 0
            sectionPills = pills
        } catch {}

        // Fitness — fetch today's WorkoutDay directly from context
        let weekday = Calendar.current.component(.weekday, from: Date()) - 1
        do {
            let desc = FetchDescriptor<WorkoutDay>(
                predicate: #Predicate<WorkoutDay> { $0.dayOfWeek == weekday }
            )
            if let wd = try context.fetch(desc).first {
                todayIsRestDay = wd.isRestDay
                todayWorkoutComplete = wd.isCompleted
                todayMuscleGroup = wd.muscleGroup
                fitnessProgress = fitnessVM.progress(for: wd)
            }
        } catch {}

        // Health
        currentWeight = healthVM.currentWeight
        lastNightSleep = healthVM.sleepEntries.first?.hours ?? healthVM.hkSleep
        sleepQuality = healthVM.sleepEntries.first?.quality

        // Learning
        currentPhaseName = learningVM.currentPhase?.title ?? "No active phase"
        currentWeekName = learningVM.currentWeek?.title ?? ""
        learningProgress = learningVM.overallProgress
        completedLearningWeeks = learningVM.completedWeeks

        // Vision
        dailyQuote = visionVM.dailyQuote
        dailyAffirmation = visionVM.dailyAffirmation

        // Tasks
        todayTaskCount = tasksVM.activeTasks.count
        overdueCount = 0
        highPriorityCount = 0

        // Journal
        journalStreak = journalVM.currentStreak
        hasJournaledToday = journalVM.todayEntry != nil
    }
}
