import SwiftUI
import SwiftData

struct ProtocolView: View {

    @Environment(\.modelContext) private var context
    @Query private var allBlocks: [ScheduleBlock]

    @State private var viewModel = ProtocolViewModel()
    @State private var showEditSheet = false


    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerArea
                .background(StackTheme.Background.base)
            ScrollView {
                VStack(spacing: StackTheme.Spacing.sm) {
                    blockList
                    editButton
                }
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, StackTheme.Spacing.md)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .navigationTitle("Protocol")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            EditScheduleSheet(selectedDay: viewModel.selectedDay)
        }
        .onAppear {
            viewModel.selectedDay = Weekday.today
        }
    }

    // MARK: - Header

    private var headerArea: some View {
        VStack(spacing: StackTheme.Spacing.md) {
            dayPicker
            let counts = viewModel.completionCount(for: viewModel.selectedDay, from: allBlocks)
            let ratio = counts.total > 0 ? Double(counts.completed) / Double(counts.total) : 0.0
            let color = StackTheme.stateColor(for: ratio)
            VStack(spacing: StackTheme.Spacing.sm) {
                HStack {
                    StackLabel("\(counts.completed) of \(counts.total) complete",
                               color: StackTheme.Text.secondary)
                    Spacer()
                    Text("\(Int(ratio * 100))%")
                        .font(StackTheme.Typography.metric)
                        .monospacedDigit()
                        .foregroundStyle(color)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.4), value: ratio)
                }
                StackProgressBar(value: ratio, color: color, height: 6)
            }
        }
        .padding(.horizontal, StackTheme.Spacing.md)
        .padding(.top, StackTheme.Spacing.md)
        .padding(.bottom, StackTheme.Spacing.sm)
    }

    // MARK: - Day picker

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: StackTheme.Spacing.xs) {
                ForEach(Weekday.mondayFirst, id: \.self) { weekday in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            viewModel.selectedDay = weekday
                        }
                    } label: {
                        StackBadge(
                            text: Weekday.shortName(for: weekday),
                            color: StackTheme.Accent.primary,
                            style: viewModel.selectedDay == weekday ? .filled : .subtle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Block list

    @ViewBuilder
    private var blockList: some View {
        let dayBlocks = viewModel.blocks(for: viewModel.selectedDay, from: allBlocks)
        let isToday = viewModel.selectedDay == Weekday.today
        let currentID = isToday ? viewModel.currentBlockID(for: dayBlocks) : nil

        if dayBlocks.isEmpty {
            ContentUnavailableView(
                "No schedule",
                systemImage: "calendar",
                description: Text("No blocks scheduled for this day.")
            )
            .padding(.vertical, StackTheme.Spacing.xl)
        } else {
            ForEach(dayBlocks) { block in
                blockRow(block, isCurrent: currentID != nil && block.persistentModelID == currentID)
            }
        }
    }

    // MARK: - Block row

    private func blockRow(_ block: ScheduleBlock, isCurrent: Bool) -> some View {
        let isExpanded = viewModel.expandedBlockIDs.contains(block.id)
        let sortedItems = block.items.sorted { $0.sortOrder < $1.sortOrder }
        let hasItems = !sortedItems.isEmpty
        let completedCount = sortedItems.filter { $0.isCompletedToday }.count

        return VStack(spacing: 0) {
            // Parent row
            HStack(spacing: 0) {
                categoryColor(for: block.category)
                    .frame(width: 3)

                HStack(spacing: StackTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ScheduleTime.display(block.time))
                            .font(StackTheme.Typography.time)
                            .foregroundStyle(isCurrent
                                ? StackTheme.Accent.primary
                                : StackTheme.Text.secondary)
                        Text(block.label)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if hasItems {
                        Text("\(completedCount)/\(sortedItems.count)")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                            .monospacedDigit()

                        Button {
                            withAnimation(.spring(duration: 0.25)) {
                                viewModel.toggleExpanded(block.id)
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(StackTheme.Text.secondary)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            completionHaptic()
                            withAnimation(.spring(duration: 0.2)) {
                                viewModel.toggleBlockCompletion(block, context: context)
                                updateDayRecord()
                            }
                        } label: {
                            Image(systemName: block.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(
                                    block.isCompletedToday
                                        ? StackTheme.Accent.primary
                                        : StackTheme.Text.tertiary
                                )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            completionHaptic()
                            withAnimation(.spring(duration: 0.2)) {
                                toggleBlock(block)
                            }
                        } label: {
                            Image(systemName: block.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(
                                    block.isCompletedToday
                                        ? StackTheme.Accent.primary
                                        : StackTheme.Text.tertiary
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, 10)
                .background(isCurrent ? StackTheme.Accent.soft : StackTheme.Background.surface)
            }

            // Expanded sub-items
            if hasItems && isExpanded {
                Rectangle()
                    .fill(StackTheme.Border.subtle)
                    .frame(height: 1)

                ForEach(sortedItems) { item in
                    itemRow(item)
                    if item.id != sortedItems.last?.id {
                        Rectangle()
                            .fill(StackTheme.Border.subtle)
                            .frame(height: 1)
                            .padding(.leading, StackTheme.Spacing.md + 20)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
        .animation(.spring(duration: 0.25), value: isExpanded)
    }

    private func itemRow(_ item: BlockItem) -> some View {
        HStack(spacing: StackTheme.Spacing.sm) {
            Text(item.title)
                .font(StackTheme.Typography.body)
                .foregroundStyle(StackTheme.Text.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                completionHaptic()
                withAnimation(.spring(duration: 0.2)) {
                    viewModel.toggleItemCompletion(item, context: context)
                    updateDayRecord()
                }
            } label: {
                Image(systemName: item.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        item.isCompletedToday
                            ? StackTheme.Accent.primary
                            : StackTheme.Text.tertiary
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, StackTheme.Spacing.md + 20)
        .padding(.trailing, StackTheme.Spacing.md)
        .padding(.vertical, 8)
        .background(StackTheme.Background.surface)
    }

    // MARK: - Edit button

    private var editButton: some View {
        Button { showEditSheet = true } label: {
            Text("Edit Schedule")
                .font(StackTheme.Typography.caption)
                .foregroundStyle(StackTheme.Text.secondary)
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, StackTheme.Spacing.sm)
                .background(StackTheme.Background.surface)
                .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, StackTheme.Spacing.sm)
    }

    // MARK: - Actions

    private func completionHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func toggleBlock(_ block: ScheduleBlock) {
        block.lastCompletedDate = block.isCompletedToday ? nil : Date()
        try? context.save()
        updateDayRecord()
    }

    private func updateDayRecord() {
        let todayBlocks = viewModel.blocks(for: Weekday.today, from: allBlocks)
        let completed = todayBlocks.filter { $0.isCompletedToday }.count
        let total = todayBlocks.count
        let ratio = total > 0 ? Double(completed) / Double(total) : 0.0
        DayRecordService.updateProtocol(ratio: ratio, for: Date().dateKey, in: context)
    }

    // MARK: - Helpers

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "morning", "nutrition":          return StackTheme.Accent.positive
        case "recovery", "ml", "career":      return StackTheme.Accent.primary
        case "fitness":                       return StackTheme.Accent.warning
        case "work", "personal":              return StackTheme.Text.secondary
        case "evening":                       return StackTheme.Text.tertiary
        default:                              return StackTheme.Accent.primary
        }
    }
}

#Preview {
    ProtocolView()
}
