import SwiftUI
import SwiftData

struct ProtocolView: View {

    enum Segment: String, CaseIterable {
        case schedule  = "Schedule"
        case checklist = "Checklist"
        case progress  = "Progress"
    }

    @Environment(\.modelContext) private var context
    @Query(sort: \ProtocolSection.sortOrder) private var sections: [ProtocolSection]

    @State private var viewModel = ProtocolViewModel()
    @State private var collapsedSections: Set<String> = []
    @State private var segment: Segment = .schedule
    @State private var selectedDayOfWeek: Int = todayDow()
    @State private var showEditSheet = false

    // MARK: - Derived

    private var totalItems: Int {
        sections.reduce(0) { $0 + $1.items.count }
    }

    private var isComplete: Bool {
        totalItems > 0 && viewModel.completedCount >= totalItems
    }

    private var progressColor: Color {
        let r = viewModel.completionRatio
        if r > 0.8 { return StackTheme.Accent.positive }
        if r > 0.4 { return StackTheme.Accent.warning }
        return StackTheme.Accent.negative
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Sticky header
            stickyHeader
                .background(StackTheme.Background.base)

            ScrollView {
                VStack(spacing: StackTheme.Spacing.sm) {
                    switch segment {
                    case .schedule:
                        ScheduleView(dayOfWeek: selectedDayOfWeek)
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .padding(.vertical, StackTheme.Spacing.md)

                    case .checklist:
                        VStack(spacing: StackTheme.Spacing.sm) {
                            Button(action: { showEditSheet = true }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("Edit Checklist")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(StackTheme.Text.tertiary)
                                }
                                .foregroundStyle(StackTheme.Accent.primary)
                                .font(StackTheme.Typography.body)
                            }
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .padding(.vertical, StackTheme.Spacing.sm)

                            checklistContent
                            if isComplete { completionCard }
                        }
                        .padding(.horizontal, StackTheme.Spacing.md)
                        .padding(.vertical, StackTheme.Spacing.md)

                    case .progress:
                        progressContent
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .padding(.vertical, StackTheme.Spacing.md)
                    }
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .navigationTitle("Protocol")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showEditSheet) {
            EditProtocolSheet()
        }
        .onAppear {
            ProtocolSeedService.seedIfNeeded(in: context)
            ScheduleSeedService.seedIfNeeded(in: context)
            selectedDayOfWeek = Self.todayDow()
            viewModel.setup(context: context)
            viewModel.totalItems = totalItems
        }
        .onChange(of: totalItems) { _, new in
            viewModel.totalItems = new
        }
        .onChange(of: isComplete) { _, complete in
            guard complete else { return }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
    }

    // MARK: - Sticky header

    private var stickyHeader: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            // Date + completion %
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.displayDateFull)
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Text.secondary)
                Spacer()
                Text(String(format: "%.0f%%", viewModel.completionRatio * 100))
                    .font(StackTheme.Typography.stat)
                    .foregroundStyle(StackTheme.Text.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.4), value: viewModel.completionRatio)
            }

            StackProgressBar(
                value: viewModel.completionRatio,
                color: progressColor,
                height: 6,
                animated: true
            )

            // 7-day Mon–Sun picker
            dayPicker

            // Segment picker
            segmentPicker
        }
        .padding(.horizontal, StackTheme.Spacing.md)
        .padding(.top, StackTheme.Spacing.md)
        .padding(.bottom, StackTheme.Spacing.sm)
    }

    // MARK: - Day picker (Mon–Sun)

    private static let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: StackTheme.Spacing.xs) {
                ForEach(0..<7, id: \.self) { dow in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedDayOfWeek = dow
                            viewModel.selectOffset(dow - Self.todayDow())
                        }
                    } label: {
                        StackBadge(
                            text: Self.dayLabels[dow],
                            color: StackTheme.Accent.primary,
                            style: selectedDayOfWeek == dow ? .filled : .subtle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Segment picker

    private var segmentPicker: some View {
        HStack(spacing: StackTheme.Spacing.sm) {
            ForEach(Segment.allCases, id: \.self) { seg in
                Button { withAnimation(.spring(duration: 0.2)) { segment = seg } } label: {
                    StackBadge(
                        text: seg.rawValue,
                        color: StackTheme.Accent.primary,
                        style: segment == seg ? .filled : .subtle
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    // MARK: - Checklist content

    @ViewBuilder
    private var checklistContent: some View {
        ForEach(sections) { section in
            ProtocolSectionCard(
                section: section,
                completedIDs: viewModel.completedItems,
                isCollapsed: collapsedSections.contains(section.id),
                onToggleCollapse: {
                    if collapsedSections.contains(section.id) {
                        collapsedSections.remove(section.id)
                    } else {
                        collapsedSections.insert(section.id)
                    }
                },
                onToggleItem: { viewModel.toggle(itemID: $0) }
            )
        }
    }

    // MARK: - Progress content

    private var progressContent: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            // Overall stat
            StackCard(elevated: true) {
                VStack(spacing: 4) {
                    Text(String(format: "%.0f%%", viewModel.completionRatio * 100))
                        .font(StackTheme.Typography.stat)
                        .foregroundStyle(progressColor)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("\(viewModel.completedCount) of \(totalItems) completed")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, StackTheme.Spacing.md)
            }

            // Per-section breakdown
            ForEach(sections) { section in
                sectionProgressRow(section)
            }

            if isComplete { completionCard }
        }
    }

    private func sectionProgressRow(_ section: ProtocolSection) -> some View {
        let done = section.items.filter { viewModel.completedItems.contains($0.id) }.count
        let total = section.items.count
        let ratio = total > 0 ? Double(done) / Double(total) : 0.0
        return StackCard {
            HStack(spacing: StackTheme.Spacing.sm) {
                Text(section.emoji).font(.body)
                Text(section.label)
                    .font(StackTheme.Typography.caption2)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .lineLimit(1)
                Spacer()
                StackProgressBar(
                    value: ratio,
                    color: ratio >= 1 ? StackTheme.Accent.positive : StackTheme.Accent.primary,
                    height: 4
                )
                .frame(width: 60)
                Text("\(done)/\(total)")
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(ratio >= 1 ? StackTheme.Accent.positive : StackTheme.Text.secondary)
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Completion card

    private var completionCard: some View {
        StackCard(elevated: true) {
            VStack(spacing: StackTheme.Spacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(StackTheme.Accent.positive)
                Text("Protocol Complete")
                    .font(StackTheme.Typography.title)
                    .foregroundStyle(StackTheme.Accent.positive)
                Text("nothing matters, so i'm playing life like a video game. and i'm winning.")
                    .font(StackTheme.Typography.caption.italic())
                    .foregroundStyle(StackTheme.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, StackTheme.Spacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Helpers

    /// ISO day-of-week: 0 = Monday … 6 = Sunday
    private static func todayDow() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday - 2 + 7) % 7
    }
}

#Preview {
    ProtocolView()
}
