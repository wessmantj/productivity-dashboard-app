import SwiftData
import Foundation

struct ProtocolSeedService {

    private struct SectionDef {
        let id: String
        let label: String
        let emoji: String
        let items: [(id: String, text: String)]
    }

    // MARK: — Public entry point

    static func seedIfNeeded(in context: ModelContext) {
        if !UserDefaults.standard.bool(forKey: "protocolV2Seeded") {
            // Clear v1 data if it exists
            if UserDefaults.standard.bool(forKey: "protocolSeeded") {
                clearAllSections(in: context)
            }
            seedV2(in: context)
            UserDefaults.standard.set(true, forKey: "protocolV2Seeded")
            UserDefaults.standard.set(true, forKey: "protocolSeeded")
        }
    }

    // MARK: — Clear old data

    private static func clearAllSections(in context: ModelContext) {
        let desc = FetchDescriptor<ProtocolSection>()
        if let sections = try? context.fetch(desc) {
            for section in sections {
                context.delete(section)
            }
        }
    }

    // MARK: — V2 seed

    private static func seedV2(in context: ModelContext) {
        let defs: [SectionDef] = [
            SectionDef(
                id: "morning", label: "MORNING PROTOCOL", emoji: "🌅",
                items: [
                    ("water_sun", "Water + 10–15 min sunlight on waking"),
                    ("vitc",      "AM Skincare — Vitamin C serum"),
                    ("toner",     "AM Skincare — Rice toner"),
                    ("ha_am",     "AM Skincare — Hyaluronic acid"),
                    ("spf",       "AM Skincare — CeraVe AM SPF 30"),
                    ("creatine",  "Creatine 5g with breakfast"),
                    ("vitd",      "Vitamin D3 2,000 IU"),
                    ("omega",     "Omega-3 1,000mg EPA/DHA"),
                    ("rhodiola",  "Rhodiola Rosea 200–400mg"),
                ]
            ),
            SectionDef(
                id: "posture", label: "POSTURE & BODY", emoji: "🧘",
                items: [
                    ("foam",       "Foam roller thoracic extensions — 3 min"),
                    ("pec",        "Doorway pec stretches — 30 sec × 2 each side"),
                    ("wall_chin",  "Wall chin tucks — 2×15, 5-sec holds"),
                    ("chin_lifts", "Supine chin tuck head lifts — 3 sets to fatigue"),
                    ("tongue",     "Tongue on palate, lips sealed all day"),
                    ("nasal",      "Nasal breathing maintained throughout day"),
                ]
            ),
            SectionDef(
                id: "throughout", label: "THROUGHOUT THE DAY", emoji: "💻",
                items: [
                    ("chin_tucks", "Chin tucks every 60–90 min (2×15 reps)"),
                    ("stand",      "Stand every 30 min — shoulder rolls + chin tucks"),
                    ("monitor",    "Monitor top at eye level, arm's length away"),
                    ("water3l",    "3 liters of water spread across the day"),
                    ("caffeine",   "Caffeine cutoff by 2pm"),
                    ("sodium",     "Sodium 1,500–2,300mg tracked"),
                    ("potassium",  "Potassium-rich food eaten today"),
                    ("thumb_pull", "Thumb pulling protocol completed"),
                ]
            ),
            SectionDef(
                id: "nutrition", label: "NUTRITION", emoji: "🥗",
                items: [
                    ("ate_well", "Ate well today — whole foods, high protein"),
                ]
            ),
            SectionDef(
                id: "neck", label: "NECK TRAINING", emoji: "💪",
                items: [
                    ("neck_mon", "Monday (Strength) — Curls 2×10–12, Extensions 2×8–10, Lateral flex 2×12–15 each side"),
                    ("neck_wed", "Wednesday (Hypertrophy) — Curls 2×12–15, Extensions 2×12–15, Lateral flex 2×15–20 each side"),
                    ("neck_fri", "Friday (Endurance) — Curls 2×15–20, Extensions 2×15–20, Lateral flex 2×20 each side"),
                ]
            ),
            SectionDef(
                id: "evening", label: "EVENING PROTOCOL", emoji: "🌙",
                items: [
                    ("sighing",     "Cyclic physiological sighing — 5 min"),
                    ("gua_sha",     "Gua sha — 5 min, face and neck"),
                    ("cleanser",    "PM Skincare — Neutrogena cleanser"),
                    ("pm_ha",       "PM Skincare — Hyaluronic acid"),
                    ("eye_cream",   "PM Skincare — Eye cream"),
                    ("tret",        "PM Skincare — Tretinoin (wait 20 min after)"),
                    ("pm_moist",    "PM Skincare — LRP Double Repair moisturizer"),
                    ("ashwa",       "Ashwagandha KSM-66 300mg with dinner"),
                    ("mag",         "Magnesium Glycinate 300–400mg"),
                    ("glycine_sup", "Glycine 3g before bed"),
                    ("theanine",    "L-Theanine 200mg before bed"),
                ]
            ),
            SectionDef(
                id: "sleep", label: "SLEEP SETUP", emoji: "😴",
                items: [
                    ("phone_out",  "Phone on charger outside your room"),
                    ("no_screens", "No screens 30–60 min before bed"),
                    ("room_temp",  "Room at 60–67°F"),
                    ("back_sleep", "Back sleeping + silk pillowcase"),
                    ("mouth_tape", "Mouth tape applied"),
                ]
            ),
            SectionDef(
                id: "checkin", label: "DAILY CHECK-IN", emoji: "🎯",
                items: [
                    ("phone_proto",    "Phone protocol followed — no mindless scroll"),
                    ("commute_intent", "Commute used intentionally (speaking / audio)"),
                    ("no_impulse",     "No impulse purchases today"),
                    ("present",        "Was present with people, not on phone"),
                    ("showed_up",      "Showed up for myself even when no one's watching"),
                    ("real_exp",       "Had at least one real experience today"),
                ]
            ),
        ]

        for (sectionOrder, def) in defs.enumerated() {
            let section = ProtocolSection(
                id: def.id,
                label: def.label,
                emoji: def.emoji,
                colorHex: "6366f1",
                sortOrder: sectionOrder
            )
            context.insert(section)
            for (itemOrder, itemDef) in def.items.enumerated() {
                let item = ProtocolItem(id: itemDef.id, text: itemDef.text, sortOrder: itemOrder)
                context.insert(item)
                section.items.append(item)
            }
        }
    }
}
