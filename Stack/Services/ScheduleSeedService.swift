import SwiftData
import Foundation

struct ScheduleSeedService {

    /// Bump this to force a one-time reseed of the weekly schedule on existing installs.
    private static let scheduleSeedVersion = 2

    private struct B {
        let time: String
        let label: String
        let category: String
        init(_ time: String, _ label: String, _ category: String) {
            self.time = time; self.label = label; self.category = category
        }
    }

    static func seedIfNeeded(in context: ModelContext) {
        // integer(forKey:) returns 0 when the key is missing (fresh installs and
        // installs from before versioned seeding), so they all reseed once.
        let stored = UserDefaults.standard.integer(forKey: "scheduleSeedVersion")
        guard stored < scheduleSeedVersion else { return }

        clearAll(in: context)
        seed(in: context)
        try? context.save()

        // clearAll cascade-deletes the old blocks' BlockItems, so reset the
        // block-item flag to let seedBlockItemsIfNeeded repopulate the fresh blocks.
        UserDefaults.standard.removeObject(forKey: "blockItemsSummerV1Seeded")
        UserDefaults.standard.set(scheduleSeedVersion, forKey: "scheduleSeedVersion")
    }

    static func seedBlockItemsIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "blockItemsSummerV1Seeded") else { return }
        guard let blocks = try? context.fetch(FetchDescriptor<ScheduleBlock>()) else { return }
        for block in blocks {
            let titles = itemTitles(for: block)
            for (i, title) in titles.enumerated() {
                let item = BlockItem()
                item.title = title
                item.sortOrder = i
                item.parentBlock = block
                context.insert(item)
            }
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: "blockItemsSummerV1Seeded")
    }

    private static func itemTitles(for block: ScheduleBlock) -> [String] {
        let label = block.label
        let day   = block.dayOfWeek

        if label == "Posture + neck lengthening — 10 min" && (2...6).contains(day) {
            return postureItems
        }
        if label == "Breakfast + AM supplements" {
            return breakfastItems
        }
        if label == "Shower + AM skincare + minox" {
            return amSkincareItems
        }
        if label.contains("PM skincare") && (2...6).contains(day) {
            return pmSkincareItems
        }
        if label == "Dinner + PM supplements" && day == 2 {
            return dinnerBaseItems
        }
        if label.contains("journal") && label.contains("debrief") && (3...6).contains(day) {
            return dinnerJournalItems
        }
        if label == "Dinner" && (day == 7 || day == 1) {
            return dinnerBaseItems
        }
        if label == "Sunday Review — money / weight / career / gratitude" && day == 1 {
            return sundayReviewItems
        }
        if isWindDownHost(label: label, day: day) {
            if label == "Extended stretch + neck endurance" && day == 5 {
                return neckItems + bedtimeItems
            }
            return bedtimeItems
        }
        return []
    }

    private static func isWindDownHost(label: String, day: Int) -> Bool {
        switch day {
        case 2: return label == "Stretch + wind down"
        case 3: return label == "Stretch + wind down"
        case 4: return label == "Stretch + wind down"
        case 5: return label == "Extended stretch + neck endurance"
        case 6: return label == "Wind down"
        case 7: return label == "Wind down + read"
        case 1: return label == "Wind down"
        default: return false
        }
    }

    private static let postureItems = [
        "Foam roller thoracic extensions — 1 min",
        "Doorway pec stretch — 30 sec × 2/side",
        "Suboccipital release — 1 min/side",
        "Levator scapulae stretch — 30 sec/side",
        "Upper trap stretch — 30 sec/side",
        "Scalene stretch — 30 sec/side",
        "Wall chin tucks — 2×15, 5 sec holds",
        "Crown lift hold — 1 min",
    ]

    private static let breakfastItems = [
        "Eat breakfast",
        "Creatine 5g",
        "Vitamin D3 2000 IU",
        "Rhodiola 200–400mg",
    ]

    private static let amSkincareItems = [
        "Shower",
        "Vitamin C serum",
        "Hyaluronic acid",
        "CeraVe SPF 30",
        "Minoxidil 1mL to hairline corners",
    ]

    private static let pmSkincareItems = [
        "Cleanser",
        "Hyaluronic acid or Tretinoin (per ramp schedule)",
        "Moisturizer (LRP Double Repair on tret nights)",
        "Eye cream",
        "Minoxidil 1mL",
    ]

    private static let dinnerBaseItems = [
        "Eat dinner",
        "Ashwagandha KSM-66 300mg",
    ]

    private static let dinnerJournalItems = [
        "Eat dinner",
        "Ashwagandha KSM-66 300mg",
        "Journal interaction debrief (5 min)",
    ]

    private static let bedtimeItems = [
        "Magnesium Glycinate 300–400mg",
        "Glycine 3g",
        "L-Theanine 200mg",
        "Mouth tape prep",
    ]

    private static let neckItems = [
        "Neck Curls 2×20",
        "Neck Extensions 2×20",
        "Lateral flex 2×20",
    ]

    private static let sundayReviewItems = [
        "Money review (15 min) — spending, CC, net worth, paycheck plan",
        "Weight progression + photo comparison (15 min)",
        "Sensata / return-offer momentum (20 min)",
        "Gratitude entry + week intentions (10 min)",
    ]

    private static func clearAll(in context: ModelContext) {
        if let blocks = try? context.fetch(FetchDescriptor<ScheduleBlock>()) {
            blocks.forEach { context.delete($0) }
        }
    }

    private static func seed(in context: ModelContext) {
        // Calendar.weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let schedule: [(dayOfWeek: Int, blocks: [B])] = [
            (2, monday),
            (3, tuesday),
            (4, wednesday),
            (5, thursday),
            (6, friday),
            (7, saturday),
            (1, sunday),
        ]
        for (dayOfWeek, blocks) in schedule {
            for (order, b) in blocks.enumerated() {
                context.insert(ScheduleBlock(
                    dayOfWeek: dayOfWeek,
                    time: b.time,
                    label: b.label,
                    category: b.category,
                    sortOrder: order
                ))
            }
        }
    }

    // MARK: — Monday (2) — PD Day, Push

    private static let monday: [B] = [
        B("6:00 AM",  "Wake — water, sunlight",                    "Morning"),
        B("6:05 AM",  "AM walk — 25 min, fasted",                  "Recovery"),
        B("6:30 AM",  "Shower + AM skincare + minox",               "Morning"),
        B("6:55 AM",  "Breakfast + AM supplements",                 "Nutrition"),
        B("7:15 AM",  "Posture + neck lengthening — 10 min",        "Recovery"),
        B("7:25 AM",  "Read aloud — 10 min",                        "ML"),
        B("7:35 AM",  "ML morning theory — 45 min",                 "ML"),
        B("8:20 AM",  "PD block",                                   "Work"),
        B("12:00 PM", "Lunch + physiological sigh breathwork",      "Nutrition"),
        B("1:00 PM",  "ML deep work — 3–4 hr",                      "ML"),
        B("5:15 PM",  "Drive to gym",                               "Fitness"),
        B("5:40 PM",  "Lift — Push (60 min)",                       "Fitness"),
        B("7:05 PM",  "Home, PM skincare + minox",                  "Evening"),
        B("7:20 PM",  "Dinner + PM supplements",                    "Nutrition"),
        B("8:05 PM",  "Personal / free time",                       "Personal"),
        B("9:30 PM",  "Stretch + wind down",                        "Evening"),
        B("10:00 PM", "Read 10 pages",                              "Personal"),
        B("10:30 PM", "Sleep",                                      "Evening"),
    ]

    // MARK: — Tuesday (3) — NBRR 9–5, Pull

    private static let tuesday: [B] = [
        B("6:00 AM",  "Wake — water, sunlight",                    "Morning"),
        B("6:05 AM",  "AM walk — 25 min, fasted",                  "Recovery"),
        B("6:30 AM",  "Shower + AM skincare + minox",               "Morning"),
        B("6:55 AM",  "Breakfast + AM supplements",                 "Nutrition"),
        B("7:15 AM",  "Posture + neck lengthening — 10 min",        "Recovery"),
        B("7:25 AM",  "Read aloud — 10 min",                        "ML"),
        B("7:35 AM",  "ML morning theory — 45 min",                 "ML"),
        B("8:20 AM",  "Commute to NBRR — 40 min",                   "Work"),
        B("9:00 AM",  "Internship (NBRR 9–5)",                      "Work"),
        B("12:00 PM", "Lunch + physiological sigh breathwork",      "Nutrition"),
        B("5:00 PM",  "End work — commute home",                    "Work"),
        B("5:45 PM",  "Drive to gym",                               "Fitness"),
        B("6:10 PM",  "Lift — Pull (60 min)",                       "Fitness"),
        B("7:35 PM",  "Home, PM skincare + minox",                  "Evening"),
        B("7:50 PM",  "Dinner + journal debrief",                   "Nutrition"),
        B("8:35 PM",  "Decompress / social / personal",             "Personal"),
        B("9:30 PM",  "Stretch + wind down",                        "Evening"),
        B("9:50 PM",  "Read 10 pages",                              "Personal"),
        B("10:30 PM", "Sleep",                                      "Evening"),
    ]

    // MARK: — Wednesday (4) — NBRR 9–5, Lower

    private static let wednesday: [B] = [
        B("6:00 AM",  "Wake — water, sunlight",                    "Morning"),
        B("6:05 AM",  "AM walk — 25 min, fasted",                  "Recovery"),
        B("6:30 AM",  "Shower + AM skincare + minox",               "Morning"),
        B("6:55 AM",  "Breakfast + AM supplements",                 "Nutrition"),
        B("7:15 AM",  "Posture + neck lengthening — 10 min",        "Recovery"),
        B("7:25 AM",  "Read aloud — 10 min",                        "ML"),
        B("7:35 AM",  "ML morning theory — 45 min",                 "ML"),
        B("8:20 AM",  "Commute to NBRR — 40 min",                   "Work"),
        B("9:00 AM",  "Internship (NBRR 9–5)",                      "Work"),
        B("12:00 PM", "Lunch + physiological sigh breathwork",      "Nutrition"),
        B("5:00 PM",  "End work — commute home",                    "Work"),
        B("5:45 PM",  "Drive to gym",                               "Fitness"),
        B("6:10 PM",  "Lift — Lower (60 min)",                      "Fitness"),
        B("7:35 PM",  "Home, PM skincare + minox",                  "Evening"),
        B("7:50 PM",  "Dinner + journal debrief",                   "Nutrition"),
        B("8:35 PM",  "Decompress / social / personal",             "Personal"),
        B("9:30 PM",  "Stretch + wind down",                        "Evening"),
        B("9:50 PM",  "Read 10 pages",                              "Personal"),
        B("10:30 PM", "Sleep",                                      "Evening"),
    ]

    // MARK: — Thursday (5) — Free day, REST + biggest ML day

    private static let thursday: [B] = [
        B("6:00 AM",  "Wake — water, sunlight",                                                  "Morning"),
        B("6:05 AM",  "AM walk — 25 min, fasted",                                                "Recovery"),
        B("6:30 AM",  "Shower + AM skincare + minox",                                             "Morning"),
        B("6:55 AM",  "Breakfast + AM supplements",                                               "Nutrition"),
        B("7:15 AM",  "Posture + neck lengthening — 10 min",                                      "Recovery"),
        B("7:25 AM",  "Read aloud — 10 min",                                                      "ML"),
        B("7:35 AM",  "ML morning theory — 45 min",                                               "ML"),
        B("8:30 AM",  "ML deep work — 3.5 hr (biggest ML day)",                                   "ML"),
        B("12:00 PM", "Lunch + physiological sigh breathwork",                                    "Nutrition"),
        B("1:00 PM",  "ML deep work — 3 hr",                                                      "ML"),
        B("4:00 PM",  "Active recovery — long walk 45–60 min + mobility 15 min + neck training",  "Recovery"),
        B("5:30 PM",  "Free / errands / decompress",                                              "Personal"),
        B("6:30 PM",  "Dinner + journal debrief",                                                 "Nutrition"),
        B("7:15 PM",  "Career block — networking / LinkedIn / applications",                      "Career"),
        B("8:15 PM",  "Personal / creative",                                                      "Personal"),
        B("9:00 PM",  "Extended stretch + neck endurance",                                        "Recovery"),
        B("9:45 PM",  "Read 10 pages",                                                            "Personal"),
        B("10:30 PM", "Sleep",                                                                    "Evening"),
    ]

    // MARK: — Friday (6) — NBRR 9–5, Upper

    private static let friday: [B] = [
        B("6:00 AM",  "Wake — water, sunlight",                                "Morning"),
        B("6:05 AM",  "AM walk — 25 min, fasted",                              "Recovery"),
        B("6:30 AM",  "Shower + AM skincare + minox",                           "Morning"),
        B("6:55 AM",  "Breakfast + AM supplements",                             "Nutrition"),
        B("7:15 AM",  "Posture + neck lengthening — 10 min",                    "Recovery"),
        B("7:25 AM",  "Read aloud — 10 min",                                    "ML"),
        B("7:35 AM",  "ML morning theory — 45 min",                             "ML"),
        B("8:20 AM",  "Commute to NBRR — 40 min",                               "Work"),
        B("9:00 AM",  "Internship (NBRR 9–5)",                                  "Work"),
        B("12:00 PM", "Lunch + physiological sigh breathwork",                  "Nutrition"),
        B("5:00 PM",  "End work — commute home",                                "Work"),
        B("5:45 PM",  "Drive to gym",                                           "Fitness"),
        B("6:10 PM",  "Lift — Upper blend (60 min)",                            "Fitness"),
        B("7:35 PM",  "Home, PM skincare + minox",                              "Evening"),
        B("7:50 PM",  "Dinner + journal debrief",                               "Nutrition"),
        B("8:35 PM",  "Protected free time — friends / games / creative",       "Personal"),
        B("10:00 PM", "Wind down",                                              "Evening"),
        B("10:30 PM", "Sleep",                                                  "Evening"),
    ]

    // MARK: — Saturday (7) — Lift + ML + social anchor

    private static let saturday: [B] = [
        B("7:00 AM",  "Wake — water, sunlight",                          "Morning"),
        B("7:15 AM",  "AM walk — 30 min",                                "Recovery"),
        B("7:45 AM",  "Shower + AM skincare + minox",                     "Morning"),
        B("8:15 AM",  "Breakfast + AM supplements",                       "Nutrition"),
        B("8:45 AM",  "Drive to gym",                                     "Fitness"),
        B("9:10 AM",  "Lift — Posterior + Abs (75–90 min)",               "Fitness"),
        B("11:10 AM", "Home, refuel (high protein)",                      "Nutrition"),
        B("11:30 AM", "ML deep work — 2.5 hr + 1 paper read",             "ML"),
        B("2:00 PM",  "Lunch",                                            "Nutrition"),
        B("2:30 PM",  "Career power hour — application + LinkedIn",       "Career"),
        B("4:00 PM",  "Protected free block — social anchor / creative",  "Personal"),
        B("7:00 PM",  "Dinner",                                           "Nutrition"),
        B("9:00 PM",  "Stretch + posture",                                "Recovery"),
        B("9:45 PM",  "Wind down + read",                                 "Personal"),
        B("10:30 PM", "Sleep",                                            "Evening"),
    ]

    // MARK: — Sunday (1) — Rest + Synthesis + Plan

    private static let sunday: [B] = [
        B("7:00 AM",  "Wake — water, sunlight",                              "Morning"),
        B("7:05 AM",  "Weigh-in + progress photo",                           "Recovery"),
        B("7:15 AM",  "30 min solitude — coffee, journal, no phone",          "Personal"),
        B("7:45 AM",  "Long walk — 45 min",                                   "Recovery"),
        B("8:30 AM",  "Breakfast + AM supplements",                           "Nutrition"),
        B("9:00 AM",  "Weekly call to friend or family",                      "Personal"),
        B("10:00 AM", "Free morning",                                         "Personal"),
        B("12:00 PM", "Lunch",                                                "Nutrition"),
        B("1:00 PM",  "Meal prep — 90 min",                                   "Nutrition"),
        B("2:30 PM",  "ML synthesis writeup — 2 hr (non-negotiable)",         "ML"),
        B("4:30 PM",  "Free time",                                            "Personal"),
        B("6:00 PM",  "Dinner",                                               "Nutrition"),
        B("7:00 PM",  "Sunday Review — money / weight / career / gratitude",  "Career"),
        B("8:00 PM",  "Light reading",                                        "Personal"),
        B("9:00 PM",  "Extended stretch + full posture sequence — 30 min",    "Recovery"),
        B("9:45 PM",  "PM skincare + PM supplements",                         "Evening"),
        B("10:00 PM", "Wind down",                                            "Evening"),
        B("10:30 PM", "Sleep",                                                "Evening"),
    ]
}
