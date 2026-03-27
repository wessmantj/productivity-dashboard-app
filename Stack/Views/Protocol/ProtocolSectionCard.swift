import SwiftUI

struct ProtocolSectionCard: View {
    let section: ProtocolSection
    let completedIDs: Set<String>
    let isCollapsed: Bool
    let onToggleCollapse: () -> Void
    let onToggleItem: (String) -> Void

    private var sortedItems: [ProtocolItem] {
        section.items.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var doneCount: Int {
        section.items.filter { completedIDs.contains($0.id) }.count
    }

    private var totalCount: Int { section.items.count }

    private var allDone: Bool { doneCount == totalCount && totalCount > 0 }

    var body: some View {
        StackCard {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header
                HStack(spacing: 10) {
                    Text(section.emoji)
                        .font(.callout)

                    Text(section.label)
                        .font(StackTheme.Typography.caption2)
                        .foregroundStyle(StackTheme.Text.primary)
                        .tracking(0.8)

                    Spacer()

                    // x/y badge
                    StackBadge(
                        text: "\(doneCount)/\(totalCount)",
                        color: StackTheme.Accent.primary,
                        style: allDone ? .filled : .subtle
                    )
                    .animation(.spring(duration: 0.3), value: allDone)

                    Image(systemName: "chevron.down")
                        .font(StackTheme.Typography.caption2)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                        .animation(.spring(duration: 0.35), value: isCollapsed)
                }
                .padding(.bottom, isCollapsed ? 0 : StackTheme.Spacing.sm)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(duration: 0.35)) { onToggleCollapse() }
                }

                // MARK: Items
                if !isCollapsed {
                    Divider()
                        .overlay(StackTheme.Border.subtle)
                        .padding(.bottom, StackTheme.Spacing.xs)

                    VStack(spacing: 0) {
                        ForEach(sortedItems) { item in
                            ProtocolItemRow(
                                item: item,
                                isCompleted: completedIDs.contains(item.id),
                                onToggle: { onToggleItem(item.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}
