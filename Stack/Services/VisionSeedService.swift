import Foundation
import SwiftData

struct VisionSeedService {

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "visionSeeded") else { return }

        // MARK: — Goals
        let goalData: [(String, String, String, String, Int)] = [
            // (title, detail, category, colorHex, sortOrder)
            ("Build a physique I'm proud of",
             "6-day progressive overload split, cutting phase, 160-190g protein daily. Show up every session.",
             "Fitness", "ef4444", 0),
            ("Master my daily protocol",
             "46-item daily system: morning routine, posture work, supplements, sleep. Stack up the days.",
             "Fitness", "f97316", 1),
            ("Become an ML/AI engineer",
             "Complete the full 7-month ML→LLM roadmap. Implement everything from scratch. No shortcuts.",
             "Career", "6366f1", 0),
            ("Ship Stack to the App Store",
             "Build a production iOS/macOS app from scratch. Own the full stack: SwiftUI, SwiftData, HealthKit, CloudKit.",
             "Career", "3b82f6", 1),
            ("Understand LLMs all the way down",
             "From linear algebra to transformers to RLHF. Read the papers. Implement the models. Explain without notes.",
             "Learning", "8b5cf6", 0),
            ("Read 12 books this year",
             "Technical and non-technical. Track progress in Stack. One book always active.",
             "Learning", "10b981", 1),
            ("Be someone I respect",
             "Disciplined. Consistent. Healthy. Building. Every day is a vote for the person you're becoming.",
             "Life", "f59e0b", 0),
        ]
        for (title, detail, cat, hex, order) in goalData {
            let g = Goal(title: title, detail: detail, category: cat, sortOrder: order, colorHex: hex)
            context.insert(g)
        }

        // MARK: — Quotes
        let quoteData: [(String, String)] = [
            ("We are what we repeatedly do. Excellence, then, is not an act, but a habit.", "Aristotle"),
            ("The man who moves a mountain begins by carrying away small stones.", "Confucius"),
            ("Hard choices, easy life. Easy choices, hard life.", "Jerzy Gregorek"),
            ("Don't count the days. Make the days count.", "Muhammad Ali"),
            ("You do not rise to the level of your goals. You fall to the level of your systems.", "James Clear"),
            ("The successful warrior is the average man, with laser-like focus.", "Bruce Lee"),
            ("Discipline is choosing between what you want now and what you want most.", "Abraham Lincoln"),
        ]
        for (i, (text, author)) in quoteData.enumerated() {
            let q = Quote(text: text, author: author, sortOrder: i)
            context.insert(q)
        }

        // MARK: — Affirmations
        let affirmationData = [
            "I show up every day, whether I feel like it or not.",
            "I am building something real. The work compounds.",
            "Every rep, every page, every line of code is moving me forward.",
            "I don't need motivation. I have a system.",
            "The version of me I'm building is worth every hard day.",
        ]
        for (i, text) in affirmationData.enumerated() {
            let a = Affirmation(text: text, sortOrder: i, isActive: true)
            context.insert(a)
        }

        UserDefaults.standard.set(true, forKey: "visionSeeded")
    }
}
