import Foundation

// MARK: - Weekday helpers (Calendar.weekday convention: 1=Sun, 2=Mon … 7=Sat)

enum Weekday {
    static let shortNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let fullNames  = ["Sunday", "Monday", "Tuesday", "Wednesday",
                             "Thursday", "Friday", "Saturday"]

    /// Monday-first ordering of Calendar.weekday values, for week-based UI.
    static let mondayFirst = [2, 3, 4, 5, 6, 7, 1]

    static var today: Int {
        Calendar.current.component(.weekday, from: Date())
    }

    static func shortName(for weekday: Int) -> String {
        guard (1...7).contains(weekday) else { return "" }
        return shortNames[weekday - 1]
    }

    static func fullName(for weekday: Int) -> String {
        guard (1...7).contains(weekday) else { return "" }
        return fullNames[weekday - 1]
    }
}

// MARK: - Schedule time strings (e.g. "7:20 AM", "10:30pm", "Variable")

enum ScheduleTime {

    /// Parses a schedule time string into minutes since midnight.
    /// Returns nil for non-clock values like "Variable" or "All day".
    static func minutes(from timeStr: String) -> Int? {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        let isPM = s.hasSuffix("pm")
        let isAM = s.hasSuffix("am")
        guard isPM || isAM else { return nil }
        let clean = s
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return nil }
        var h = parts[0]
        let m = parts.count > 1 ? parts[1] : 0
        if isPM && h != 12 { h += 12 }
        if isAM && h == 12 { h = 0 }
        return h * 60 + m
    }

    /// Normalizes a schedule time string for display: "7:20am" → "7:20 AM".
    /// Non-clock values pass through unchanged.
    static func display(_ timeStr: String) -> String {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        let isPM = s.hasSuffix("pm")
        let isAM = s.hasSuffix("am")
        guard isPM || isAM else { return timeStr }
        let clean = s
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return timeStr }
        let h = parts[0]
        let m = parts.count > 1 ? parts[1] : 0
        return String(format: "%d:%02d %@", h, m, isPM ? "PM" : "AM")
    }

    /// Builds a schedule time string ("7:20 PM") from hour/minute components.
    static func string(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayH = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour
        return String(format: "%d:%02d %@", displayH, minute, period)
    }

    static func minutesSinceMidnight(of date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
    }

    /// The block whose time window contains `date` (a block runs until the next
    /// block on the same day starts).
    static func currentBlock(in blocks: [ScheduleBlock], at date: Date = Date()) -> ScheduleBlock? {
        let nowMin = minutesSinceMidnight(of: date)
        let timed = blocks.compactMap { block -> (ScheduleBlock, Int)? in
            guard let min = minutes(from: block.time) else { return nil }
            return (block, min)
        }.sorted { $0.1 < $1.1 }

        for (idx, (block, blockMin)) in timed.enumerated() {
            let nextMin = idx + 1 < timed.count ? timed[idx + 1].1 : Int.max
            if nowMin >= blockMin && nowMin < nextMin {
                return block
            }
        }
        return nil
    }
}

// MARK: - Date keys & display formatting

extension Date {

    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let longDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f
    }()

    /// Stable per-day key, e.g. "2026-06-11". Used by DayRecord and daily resets.
    var dateKey: String {
        Self.dateKeyFormatter.string(from: self)
    }

    /// Long display form, e.g. "Thursday, June 11".
    var longDisplay: String {
        Self.longDisplayFormatter.string(from: self)
    }

    static func fromDateKey(_ key: String) -> Date? {
        dateKeyFormatter.date(from: key)
    }
}

// MARK: - Safe collection access

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
