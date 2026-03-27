import SwiftUI

struct TodayJournalView: View {
    let viewModel: JournalViewModel
    @State private var showSheet = false

    private static let moods: [Int: String]      = [1:"😔",2:"😕",3:"😐",4:"🙂",5:"😄"]
    private static let moodLabels: [Int: String]  = [1:"Rough",2:"Fair",3:"Okay",4:"Good",5:"Excellent"]

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.lg) {
                if let entry = viewModel.todayEntry {
                    // Entry card
                    entryCard(entry)
                } else {
                    // Empty state prompt card
                    StackCard {
                        VStack(spacing: StackTheme.Spacing.md) {
                            Text("😐")
                                .font(.system(size: 48))

                            VStack(spacing: StackTheme.Spacing.xs) {
                                Text("Today's entry")
                                    .font(StackTheme.Typography.headline)
                                    .foregroundStyle(StackTheme.Text.primary)

                                Text(Date().formatted(.dateTime.weekday().month().day()))
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.tertiary)
                            }

                            Button {
                                showSheet = true
                            } label: {
                                Text("Write Now →")
                                    .font(StackTheme.Typography.body.bold())
                                    .foregroundStyle(StackTheme.Text.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, StackTheme.Spacing.sm)
                                    .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    }
                }

                // Streak badge
                if viewModel.currentStreak >= 2 {
                    StackBadge(
                        text: "🔥 \(viewModel.currentStreak) day streak",
                        color: StackTheme.Accent.positive,
                        style: .filled
                    )
                }

                // Edit / Write button
                Button {
                    showSheet = true
                } label: {
                    Label(viewModel.todayEntry == nil ? "Start Writing" : "Edit Entry",
                          systemImage: viewModel.todayEntry == nil ? "square.and.pencil" : "pencil")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StackTheme.Spacing.md)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, StackTheme.Spacing.md)
            .padding(.vertical, StackTheme.Spacing.lg)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showSheet) {
            JournalEntrySheet(viewModel: viewModel, existing: viewModel.todayEntry)
        }
    }

    // MARK: — Entry card

    private func entryCard(_ entry: JournalEntry) -> some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                HStack {
                    Text(Self.moods[entry.mood] ?? "😐")
                        .font(StackTheme.Typography.title)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(Self.moodLabels[entry.mood] ?? "Okay")
                            .font(StackTheme.Typography.headline)
                            .foregroundStyle(StackTheme.Text.secondary)
                        Text(entry.date.formatted(.dateTime.weekday().month().day()))
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }

                    Spacer()

                    HStack(spacing: StackTheme.Spacing.xs) {
                        StackBadge(
                            text: "\(entry.wordCount) words",
                            color: StackTheme.Accent.primary,
                            style: .subtle
                        )
                        if viewModel.currentStreak >= 2 {
                            StackBadge(
                                text: "🔥 \(viewModel.currentStreak)",
                                color: StackTheme.Accent.positive,
                                style: .filled
                            )
                        }
                    }
                }

                Text(entry.body)
                    .font(StackTheme.Typography.body)
                    .lineSpacing(5)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: StackTheme.Spacing.xs) {
                            ForEach(entry.tags, id: \.self) { tag in
                                StackBadge(text: "#\(tag)", color: StackTheme.Accent.primary, style: .subtle)
                            }
                        }
                    }
                }
            }
        }
    }
}
