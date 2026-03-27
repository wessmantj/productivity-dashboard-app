import SwiftUI

struct CardioView: View {
    let viewModel: HealthViewModel
    @State private var showLog = false

    private static let dateF: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none; return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                // MARK: — Summary card
                summaryCard

                // MARK: — Recent sessions
                if viewModel.cardioEntries.isEmpty {
                    ContentUnavailableView(
                        "No cardio logged",
                        systemImage: "figure.run",
                        description: Text("Tap the button above to log your first session.")
                    )
                } else {
                    VStack(spacing: StackTheme.Spacing.sm) {
                        StackSectionHeader(title: "RECENT")
                            .padding(.horizontal, StackTheme.Spacing.xs)

                        ForEach(viewModel.cardioEntries) { entry in
                            StackCard {
                                cardioRow(entry)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteCardio(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base)
        .sheet(isPresented: $showLog) { LogCardioSheet(viewModel: viewModel) }
    }

    // MARK: — Summary card

    private var summaryCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                HStack {
                    Label("Cardio", systemImage: "figure.run")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Accent.primary)
                    Spacer()
                    if let cal = viewModel.hkCalories {
                        StackBadge(
                            text: "\(cal) kcal today",
                            color: StackTheme.Accent.primary,
                            style: .subtle
                        )
                    }
                }

                HStack(spacing: StackTheme.Spacing.sm) {
                    StackStatCard(
                        value: "\(viewModel.weeklyCardioCount)",
                        label: "Sessions",
                        icon: "figure.run",
                        iconColor: StackTheme.Accent.primary
                    )

                    StackStatCard(
                        value: "\(viewModel.weeklyCardioMinutes)",
                        unit: "min",
                        label: "Total Min",
                        icon: "clock.fill",
                        iconColor: StackTheme.Accent.primary
                    )
                }

                Button { showLog = true } label: {
                    Text("Log Cardio")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: — Cardio row

    private func cardioRow(_ entry: CardioEntry) -> some View {
        HStack(spacing: StackTheme.Spacing.sm) {
            Image(systemName: icon(for: entry.type))
                .font(.title3)
                .foregroundStyle(StackTheme.Accent.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                Text(entry.type)
                    .font(StackTheme.Typography.headline)
                    .foregroundStyle(StackTheme.Text.primary)
                HStack(spacing: StackTheme.Spacing.sm) {
                    Label("\(entry.durationMinutes) min", systemImage: "clock")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                    if entry.distanceMiles > 0 {
                        Label(String(format: "%.1f mi", entry.distanceMiles), systemImage: "map")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                    if entry.calories > 0 {
                        Label("\(entry.calories) kcal", systemImage: "flame")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }

            Spacer()
            Text(Self.dateF.string(from: entry.date))
                .font(StackTheme.Typography.caption2)
                .foregroundStyle(StackTheme.Text.tertiary)
        }
    }

    private func icon(for type: String) -> String {
        switch type {
        case "Run":          return "figure.run"
        case "Walk":         return "figure.walk"
        case "Bike":         return "figure.outdoor.cycle"
        case "Stairmaster":  return "figure.stair.stepper"
        case "Swim":         return "figure.pool.swim"
        default:             return "figure.mixed.cardio"
        }
    }
}
