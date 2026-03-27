import SwiftUI

// MARK: — Supporting types

private struct TappedCell: Identifiable {
    let id = UUID()
    let date: Date
    let record: DayRecord?
}

// MARK: — HeatmapCard

struct HeatmapCard: View {

    let title: String
    let type: HeatmapType
    let viewModel: ProgressViewModel

    @State private var isExpanded: Bool = true
    @State private var appeared:   Bool = false
    @State private var tappedCell: TappedCell? = nil

    // Layout constants
    private let cellSize: CGFloat = 11
    private let cellGap:  CGFloat = 2
    private let cal = Calendar.current

    // MARK: - Derived data

    private var colWidth: CGFloat { cellSize + cellGap }

    private var gridYear: Int { cal.component(.year, from: Date()) }

    private var gridStartDate: Date {
        cal.date(from: DateComponents(year: gridYear, month: 1, day: 1))!
    }

    /// How many rows into a Mon–Sun week column Jan 1 falls (0=Mon, 6=Sun)
    private var jan1Offset: Int {
        let wd = cal.component(.weekday, from: gridStartDate) // 1=Sun…7=Sat
        return (wd - 2 + 7) % 7
    }

    private var weeks: [[Date?]] {
        let jan1   = gridStartDate
        let offset = jan1Offset
        return (0..<53).map { wk in
            (0..<7).map { day in
                let idx = wk * 7 + day - offset
                guard idx >= 0 else { return nil }
                let d = cal.date(byAdding: .day, value: idx, to: jan1)!
                return cal.component(.year, from: d) == gridYear ? d : nil
            }
        }
    }

    private var monthPositions: [(label: String, column: Int)] {
        let names  = ["Jan","Feb","Mar","Apr","May","Jun",
                      "Jul","Aug","Sep","Oct","Nov","Dec"]
        let jan1   = gridStartDate
        let offset = jan1Offset
        return (1...12).compactMap { m in
            guard let first = cal.date(from: DateComponents(year: gridYear, month: m, day: 1)) else { return nil }
            let diff = cal.dateComponents([.day], from: jan1, to: first).day ?? 0
            let col  = (diff + offset) / 7
            guard col >= 0 && col < 53 else { return nil }
            return (names[m - 1], col)
        }
    }

    private var currentWeekIndex: Int {
        let diff = cal.dateComponents([.day], from: gridStartDate, to: Date()).day ?? 0
        return max(0, min(52, (diff + jan1Offset) / 7))
    }

    private var fmt: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }

    // MARK: - Body

    var body: some View {
        StackCard(padding: 12) {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                headerRow

                if isExpanded {
                    heatmapGrid
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    legendRow
                        .transition(.opacity)
                }
            }
        }
        .sheet(item: $tappedCell) { cell in
            CellDetailSheet(date: cell.date, record: cell.record, type: type)
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: StackTheme.Spacing.sm) {
                Text(title.uppercased())
                    .font(StackTheme.Typography.label)
                    .foregroundStyle(StackTheme.Text.secondary)
                Spacer()
                StackBadge(
                    text: "\(viewModel.activeDays(for: type)) days",
                    color: StackTheme.Accent.primary,
                    style: .subtle
                )
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(StackTheme.Typography.label)
                    .foregroundStyle(StackTheme.Text.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grid

    private var heatmapGrid: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: cellGap) {
                    monthLabelsRow
                    weekColumnsRow
                }
            }
            .onAppear {
                appeared = true
                DispatchQueue.main.async {
                    proxy.scrollTo(currentWeekIndex, anchor: .trailing)
                }
            }
        }
    }

    private var monthLabelsRow: some View {
        let totalW = CGFloat(53) * colWidth
        return ZStack(alignment: .topLeading) {
            Color.clear.frame(width: totalW, height: 16)
            ForEach(monthPositions, id: \.label) { item in
                Text(item.label)
                    .font(StackTheme.Typography.label)
                    .foregroundStyle(StackTheme.Text.tertiary)
                    .offset(x: CGFloat(item.column) * colWidth)
            }
        }
        .frame(height: 16)
    }

    private var weekColumnsRow: some View {
        let rDict  = viewModel.recordsByKey
        let offset = jan1Offset
        return HStack(alignment: .top, spacing: cellGap) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { colIdx, week in
                let startRow = colIdx == 0 ? offset : 0
                VStack(spacing: cellGap) {
                    ForEach(startRow..<7, id: \.self) { rowIdx in
                        cell(date: week[rowIdx], colIdx: colIdx, dict: rDict)
                    }
                }
                .padding(.top, colIdx == 0 ? CGFloat(offset) * colWidth : 0)
                .id(colIdx)
            }
        }
    }

    @ViewBuilder
    private func cell(date: Date?, colIdx: Int, dict: [String: DayRecord]) -> some View {
        let key      = date.map { fmt.string(from: $0) }
        let record   = key.flatMap { dict[$0] }
        let lvl      = date != nil
            ? (record.map { viewModel.intensity(for: $0, type: type) } ?? .none)
            : .none
        let isToday  = date.map { cal.isDateInToday($0) } ?? false
        let inYear   = date != nil

        RoundedRectangle(cornerRadius: 2)
            .fill(inYear ? cellColor(lvl) : Color.clear)
            .frame(width: cellSize, height: cellSize)
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white.opacity(0.75), lineWidth: 1)
                }
            }
            .opacity(appeared ? 1 : 0)
            .animation(
                .easeIn(duration: 0.3).delay(Double(colIdx) * 0.002),
                value: appeared
            )
            .onTapGesture {
                if let d = date, inYear {
                    tappedCell = TappedCell(date: d, record: record)
                }
            }
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: StackTheme.Spacing.md) {
            Spacer()
            ForEach(
                [(IntensityLevel.low, "Low"),
                 (.medium, "Medium"),
                 (.high, "High")],
                id: \.1
            ) { lvl, label in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(lvl))
                        .frame(width: cellSize, height: cellSize)
                    Text(label)
                        .font(StackTheme.Typography.label)
                        .foregroundStyle(StackTheme.Text.tertiary)
                }
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Helpers

    private func cellColor(_ level: IntensityLevel) -> Color {
        switch level {
        case .none:   return StackTheme.Background.elevated
        case .low:    return StackTheme.Accent.primary.opacity(0.25)
        case .medium: return StackTheme.Accent.primary.opacity(0.6)
        case .high:   return StackTheme.Accent.primary
        }
    }
}

// MARK: — Cell detail sheet

private struct CellDetailSheet: View {
    let date: Date
    let record: DayRecord?
    let type: HeatmapType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                Text(date.formatted(.dateTime.weekday(.wide).month().day().year()))
                    .font(StackTheme.Typography.headline)
                    .foregroundStyle(StackTheme.Text.primary)

                Divider().background(StackTheme.Border.subtle)

                if let rec = record {
                    valueRows(rec)
                } else {
                    Text("No data recorded for this day.")
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.secondary)
                }

                Spacer()
            }
            .padding(StackTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(260)])
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
    }

    @ViewBuilder
    private func valueRows(_ rec: DayRecord) -> some View {
        switch type {
        case .protocol_:
            row(label: "Protocol", value: "\(Int(rec.protocolRatio * 100))% completed")
        case .workout:
            row(label: "Workout", value: rec.workoutCompleted ? "Completed ✓" : "Not logged")
        case .journal:
            row(label: "Journal", value: rec.journalWritten ? "Written ✓" : "Not logged")
        case .learning:
            row(label: "Learning", value: String(format: "%.1f hours", rec.learningHours))
        case .overall:
            row(label: "Protocol",  value: "\(Int(rec.protocolRatio * 100))%")
            row(label: "Workout",   value: rec.workoutCompleted ? "✓" : "—")
            row(label: "Journal",   value: rec.journalWritten   ? "✓" : "—")
            row(label: "Learning",  value: String(format: "%.1f hrs", rec.learningHours))
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(StackTheme.Typography.body)
                .foregroundStyle(StackTheme.Text.secondary)
            Spacer()
            Text(value)
                .font(StackTheme.Typography.body.bold())
                .foregroundStyle(StackTheme.Text.primary)
        }
    }
}
