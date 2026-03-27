import SwiftUI
import SwiftData

struct ScheduleView: View {

    @Query private var blocks: [ScheduleBlock]
    @State private var now = Date()

    init(dayOfWeek: Int) {
        _blocks = Query(
            filter: #Predicate<ScheduleBlock> { $0.dayOfWeek == dayOfWeek },
            sort: \.sortOrder
        )
    }

    // MARK: — Body

    var body: some View {
        VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
            if blocks.isEmpty {
                ContentUnavailableView(
                    "No schedule",
                    systemImage: "calendar",
                    description: Text("No blocks found for this day.")
                )
                .foregroundStyle(StackTheme.Text.secondary)
                .padding(.vertical, StackTheme.Spacing.xl)
            } else {
                ForEach(blocks) { block in
                    blockRow(block)
                }
                legend
                    .padding(.top, StackTheme.Spacing.sm)
            }
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
    }

    // MARK: — Block row

    private func blockRow(_ block: ScheduleBlock) -> some View {
        let current = isCurrentBlock(block)
        return HStack(spacing: 0) {
            // Left border strip
            borderColor(for: block.category)
                .frame(width: 3)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: StackTheme.Radius.md,
                    bottomLeadingRadius: StackTheme.Radius.md,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                ))

            HStack(alignment: .firstTextBaseline, spacing: StackTheme.Spacing.sm) {
                Text(block.time)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(StackTheme.Text.secondary)
                    .frame(width: 64, alignment: .leading)

                Text(block.label)
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, StackTheme.Spacing.md)
            .padding(.vertical, 9)
            .background(current ? StackTheme.Accent.soft : StackTheme.Background.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
    }

    // MARK: — Legend

    private var legend: some View {
        let categories: [(String, String)] = [
            ("morning",  "Morning"),
            ("class",    "Class"),
            ("deepwork", "Deep Work"),
            ("gym",      "Gym"),
            ("body",     "Body"),
            ("commute",  "Commute"),
            ("evening",  "Evening"),
            ("sleep",    "Sleep"),
            ("free",     "Free"),
        ]
        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 90), spacing: StackTheme.Spacing.xs)],
            alignment: .leading,
            spacing: StackTheme.Spacing.xs
        ) {
            ForEach(categories, id: \.0) { cat, label in
                HStack(spacing: 5) {
                    Circle()
                        .fill(borderColor(for: cat))
                        .frame(width: 6, height: 6)
                    Text(label)
                        .font(StackTheme.Typography.label)
                        .foregroundStyle(StackTheme.Text.tertiary)
                }
            }
        }
        .padding(.horizontal, StackTheme.Spacing.xs)
    }

    // MARK: — Current block detection

    private func isCurrentBlock(_ block: ScheduleBlock) -> Bool {
        guard let blockMin = minutesSinceMidnight(block.time) else { return false }
        let currentMin = minutesSinceMidnight(now)
        let sortedMins = blocks.compactMap { minutesSinceMidnight($0.time) }
        guard let nextMin = sortedMins.first(where: { $0 > blockMin }) else {
            return currentMin >= blockMin
        }
        return currentMin >= blockMin && currentMin < nextMin
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
    }

    private func minutesSinceMidnight(_ timeStr: String) -> Int? {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        guard s != "variable", s != "all day" else { return nil }
        let isPM = s.hasSuffix("pm")
        let clean = s.replacingOccurrences(of: "pm", with: "").trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        var h = parts[0], m = parts[1]
        if isPM && h != 12 { h += 12 }
        if !isPM && h == 12 { h = 0 }
        return h * 60 + m
    }

    // MARK: — Category colors

    private func borderColor(for category: String) -> Color {
        switch category {
        case "morning":  return StackTheme.Accent.primary
        case "deepwork": return StackTheme.Accent.primary.opacity(0.8)
        case "class":    return StackTheme.Accent.primary.opacity(0.6)
        case "evening":  return StackTheme.Accent.primary.opacity(0.5)
        case "commute":  return StackTheme.Accent.primary.opacity(0.4)
        case "sleep":    return StackTheme.Text.tertiary
        case "gym":      return StackTheme.Accent.negative
        case "body":     return StackTheme.Accent.positive
        case "free":     return StackTheme.Accent.positive.opacity(0.6)
        default:         return StackTheme.Text.tertiary
        }
    }
}
