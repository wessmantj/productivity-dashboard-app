import SwiftData
import Foundation

struct ScheduleSeedService {

    private struct B {
        let time: String
        let label: String
        let category: String
        init(_ time: String, _ label: String, _ category: String) {
            self.time = time; self.label = label; self.category = category
        }
    }

    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "scheduleSeedled") else { return }

        let allDays: [[B]] = [
            monday, tuesday, wednesday, thursday, friday, saturday, sunday
        ]

        for (dow, blocks) in allDays.enumerated() {
            for (order, b) in blocks.enumerated() {
                context.insert(ScheduleBlock(
                    dayOfWeek: dow,
                    time: b.time,
                    label: b.label,
                    category: b.category,
                    sortOrder: order
                ))
            }
        }

        UserDefaults.standard.set(true, forKey: "scheduleSeedled")
    }

    // MARK: — Monday (0)

    private static let monday: [B] = [
        B("6:00",  "Wake — water, sunlight",                        "morning"),
        B("6:10",  "Shower + AM skincare + dressed",                 "morning"),
        B("6:40",  "Breakfast",                                      "morning"),
        B("6:55",  "Stretch + posture + treadmill walk",             "body"),
        B("7:30",  "Supplements, pack bag, leave",                   "morning"),
        B("7:50",  "Commute — speaking practice",                    "commute"),
        B("8:10",  "On campus — review notes",                       "class"),
        B("9:00",  "DION 115",                                       "class"),
        B("10:00", "LIB 205",                                        "class"),
        B("11:00", "Deep work — coding / ML / coursework",           "deepwork"),
        B("12:00", "DION 116",                                       "class"),
        B("1:00",  "Deep work — coding / ML / coursework",           "deepwork"),
        B("2:00",  "LIB 205",                                        "class"),
        B("3:00",  "CITS — deep work block",                         "deepwork"),
        B("7:00",  "Leave campus → gym (14 min)",                    "commute"),
        B("7:15",  "Gym — weight training (75 min)",                 "gym"),
        B("8:30",  "Leave gym → home (24 min)",                      "commute"),
        B("8:54",  "Home — PM skincare + supplements",               "evening"),
        B("9:15",  "Dinner",                                         "evening"),
        B("9:45",  "Treadmill + stretch + posture work",             "body"),
        B("10:30", "Sleep",                                          "sleep"),
    ]

    // MARK: — Tuesday (1)

    private static let tuesday: [B] = [
        B("6:00",  "Wake — water, sunlight",                        "morning"),
        B("6:10",  "Shower + AM skincare + dressed",                 "morning"),
        B("6:40",  "Breakfast",                                      "morning"),
        B("6:55",  "Stretch + posture work (15 min)",                "body"),
        B("7:10",  "Supplements, pack bag, leave",                   "morning"),
        B("7:10",  "Commute — speaking practice",                    "commute"),
        B("7:30",  "CITS — deep work block",                         "deepwork"),
        B("9:30",  "SENG 331",                                       "class"),
        B("12:15", "Lunch + decompress",                             "free"),
        B("1:00",  "CITS — deep work block",                         "deepwork"),
        B("5:00",  "Leave campus → gym (14 min)",                    "commute"),
        B("5:14",  "Gym — weight training (75 min)",                 "gym"),
        B("6:30",  "Leave gym → home (24 min)",                      "commute"),
        B("6:54",  "Home — PM skincare + supplements",               "evening"),
        B("7:15",  "Dinner",                                         "evening"),
        B("7:45",  "Decompress — free time",                         "free"),
        B("9:00",  "Treadmill + stretch + posture work",             "body"),
        B("9:50",  "Wind down — light reading",                      "evening"),
        B("10:30", "Sleep",                                          "sleep"),
    ]

    // MARK: — Wednesday (2)

    private static let wednesday: [B] = [
        B("6:00",  "Wake — water, sunlight",                        "morning"),
        B("6:10",  "Shower + AM skincare + dressed",                 "morning"),
        B("6:40",  "Breakfast",                                      "morning"),
        B("7:00",  "Supplements, pack bag, leave",                   "morning"),
        B("7:20",  "Commute — speaking practice",                    "commute"),
        B("8:10",  "On campus — review notes",                       "class"),
        B("9:00",  "DION 115",                                       "class"),
        B("10:00", "LIB 205",                                        "class"),
        B("11:00", "Light deep work — coursework review",            "deepwork"),
        B("12:00", "DION 116",                                       "class"),
        B("1:00",  "Light deep work — coursework review",            "deepwork"),
        B("2:00",  "LIB 205",                                        "class"),
        B("3:00",  "DION 311",                                       "class"),
        B("5:00",  "CITS — deep work block",                         "deepwork"),
        B("7:00",  "Leave campus → gym (14 min)",                    "commute"),
        B("7:14",  "Gym — weight training (75 min)",                 "gym"),
        B("8:30",  "Leave gym → home (24 min)",                      "commute"),
        B("8:54",  "Home — PM skincare + supplements",               "evening"),
        B("9:15",  "Dinner",                                         "evening"),
        B("9:45",  "Treadmill + stretch + posture work",             "body"),
        B("10:30", "Sleep",                                          "sleep"),
    ]

    // MARK: — Thursday (3)

    private static let thursday: [B] = [
        B("6:00",  "Wake — water, sunlight",                                       "morning"),
        B("6:10",  "Shower + AM skincare + dressed",                                "morning"),
        B("6:40",  "Breakfast",                                                     "morning"),
        B("6:55",  "Treadmill walk (25 min)",                                       "body"),
        B("7:20",  "Deep work block 1 — Theory (reading, math, primary sources)",   "deepwork"),
        B("10:00", "Break — walk, snack",                                           "free"),
        B("10:15", "Deep work block 2 — Implementation (no AI)",                    "deepwork"),
        B("1:00",  "Lunch — real break, step outside",                              "free"),
        B("2:00",  "Deep work block 3 — Implementation continued",                  "deepwork"),
        B("4:30",  "Synthesis — plain English writeup, update repo",                "deepwork"),
        B("5:30",  "Dinner + decompress",                                           "free"),
        B("6:15",  "Leave → gym (24 min)",                                          "commute"),
        B("6:39",  "Gym — weight training (75 min)",                                "gym"),
        B("7:54",  "Leave gym → home (24 min)",                                     "commute"),
        B("8:18",  "Home — PM skincare + supplements",                              "evening"),
        B("8:35",  "Wind down",                                                     "evening"),
        B("9:00",  "Stretch + posture work (30 min)",                               "body"),
        B("9:30",  "Light reading",                                                 "evening"),
        B("10:30", "Sleep",                                                         "sleep"),
    ]

    // MARK: — Friday (4)

    private static let friday: [B] = [
        B("6:00",  "Wake — water, sunlight",                        "morning"),
        B("6:10",  "Shower + AM skincare + dressed",                 "morning"),
        B("6:40",  "Breakfast",                                      "morning"),
        B("7:00",  "Supplements, pack bag, leave",                   "morning"),
        B("7:20",  "Commute — speaking practice",                    "commute"),
        B("8:10",  "On campus — review notes",                       "class"),
        B("9:00",  "DION 115",                                       "class"),
        B("10:00", "LIB 205",                                        "class"),
        B("11:00", "Deep work — coding / ML",                        "deepwork"),
        B("12:00", "DION 116",                                       "class"),
        B("1:00",  "Deep work — coding / ML",                        "deepwork"),
        B("2:00",  "LIB 205",                                        "class"),
        B("3:00",  "CITS — deep work block",                         "deepwork"),
        B("5:00",  "Leave campus → gym (14 min)",                    "commute"),
        B("5:14",  "Gym — weight training (75 min)",                 "gym"),
        B("6:30",  "Leave gym → home (24 min)",                      "commute"),
        B("6:54",  "Home — PM skincare + supplements",               "evening"),
        B("7:15",  "Dinner",                                         "evening"),
        B("7:45",  "Free time — friends, games, creative outlet",    "free"),
        B("9:00",  "Treadmill + stretch + posture work",             "body"),
        B("9:45",  "Wind down",                                      "evening"),
        B("10:30", "Sleep",                                          "sleep"),
    ]

    // MARK: — Saturday (5)

    private static let saturday: [B] = [
        B("6:30",   "Wake — water, sunlight",                            "morning"),
        B("6:40",   "Shower + AM skincare + dressed",                     "morning"),
        B("7:10",   "Breakfast",                                          "morning"),
        B("7:30",   "Leave → gym (24 min)",                               "commute"),
        B("7:54",   "Gym — weight training (75–90 min)",                  "gym"),
        B("9:30",   "Leave gym → home",                                   "commute"),
        B("9:54",   "Home — decompress",                                  "free"),
        B("10:30",  "Anchor task — errands / groceries / room",           "deepwork"),
        B("12:30",  "Free day — friends, adventure, creative outlet",     "free"),
        B("9:00pm", "Treadmill + stretch + posture work",                 "body"),
        B("9:45pm", "Wind down",                                          "evening"),
        B("10:30pm","Sleep",                                              "sleep"),
    ]

    // MARK: — Sunday (6)

    private static let sunday: [B] = [
        B("Variable", "Wake when ready — morning routine before leaving", "morning"),
        B("All day",  "F&F Delivery",                                      "deepwork"),
        B("8:00pm",   "Weekly review — 5 sectors check-in (15 min)",       "deepwork"),
        B("8:15pm",   "Prepare for week — bag packed, intentions set",      "morning"),
        B("9:00pm",   "Treadmill + full stretch + posture work (45 min)",   "body"),
        B("9:45pm",   "PM skincare + supplements",                          "evening"),
        B("10:00pm",  "Wind down — light reading",                          "evening"),
        B("10:30pm",  "Sleep",                                              "sleep"),
    ]
}
