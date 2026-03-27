import Foundation
import Observation
import SwiftData

@Observable
final class VisionViewModel {

    private(set) var goals: [Goal] = []
    private(set) var quotes: [Quote] = []
    private(set) var affirmations: [Affirmation] = []

    static let categoryOrder = ["Fitness", "Career", "Learning", "Life"]

    var activeGoals: [Goal]   { goals.filter { !$0.isAchieved } }
    var achievedGoals: [Goal] { goals.filter { $0.isAchieved } }

    var goalsByCategory: [String: [Goal]] {
        Dictionary(grouping: goals) { $0.category }
    }

    var dailyQuote: Quote? {
        guard !quotes.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[day % quotes.count]
    }

    var dailyAffirmation: Affirmation? {
        let active = affirmations.filter { $0.isActive }.sorted { $0.sortOrder < $1.sortOrder }
        guard !active.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return active[day % active.count]
    }

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        VisionSeedService.seedIfNeeded(context: context)
        loadAll()
    }

    private func loadAll() {
        guard let ctx = modelContext else { return }
        do {
            let gDesc = FetchDescriptor<Goal>(
                sortBy: [SortDescriptor(\.category), SortDescriptor(\.sortOrder)]
            )
            goals = try ctx.fetch(gDesc)

            let qDesc = FetchDescriptor<Quote>(sortBy: [SortDescriptor(\.sortOrder)])
            quotes = try ctx.fetch(qDesc)

            let aDesc = FetchDescriptor<Affirmation>(sortBy: [SortDescriptor(\.sortOrder)])
            affirmations = try ctx.fetch(aDesc)
        } catch {}
    }

    // MARK: - Goals

    func addGoal(title: String, detail: String, category: String,
                 targetDate: Date?, colorHex: String) {
        guard let ctx = modelContext else { return }
        let order = goals.filter { $0.category == category }.count
        let g = Goal(title: title, detail: detail, category: category,
                     targetDate: targetDate, sortOrder: order, colorHex: colorHex)
        ctx.insert(g)
        goals.append(g)
        goals.sort { $0.category == $1.category ? $0.sortOrder < $1.sortOrder : $0.category < $1.category }
    }

    func toggleGoalAchieved(_ goal: Goal) {
        goal.isAchieved.toggle()
        goal.achievedDate = goal.isAchieved ? Date() : nil
    }

    func deleteGoal(_ goal: Goal) {
        guard let ctx = modelContext else { return }
        ctx.delete(goal)
        goals.removeAll { $0 === goal }
    }

    // MARK: - Quotes

    func addQuote(text: String, author: String) {
        guard let ctx = modelContext else { return }
        let q = Quote(text: text, author: author, sortOrder: quotes.count)
        ctx.insert(q)
        quotes.append(q)
    }

    func toggleQuoteFavorite(_ quote: Quote) {
        quote.isFavorite.toggle()
    }

    func deleteQuote(_ quote: Quote) {
        guard let ctx = modelContext else { return }
        ctx.delete(quote)
        quotes.removeAll { $0 === quote }
    }

    // MARK: - Affirmations

    func addAffirmation(text: String) {
        guard let ctx = modelContext else { return }
        let a = Affirmation(text: text, sortOrder: affirmations.count)
        ctx.insert(a)
        affirmations.append(a)
    }
}
