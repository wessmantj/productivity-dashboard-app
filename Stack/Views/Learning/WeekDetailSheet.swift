import SwiftUI

struct WeekDetailSheet: View {
    let week: LearningWeek
    let viewModel: LearningViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var theoryStep: Double = 0
    @State private var implStep: Double = 0
    @State private var synthStep: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // MARK: — Topics
                    StackSectionHeader(title: "Topics")

                    StackCard {
                        VStack(spacing: 0) {
                            ForEach(week.topics.sorted { $0.order < $1.order }) { topic in
                                topicRow(topic)
                                if topic.id != week.topics.sorted(by: { $0.order < $1.order }).last?.id {
                                    Divider()
                                        .background(StackTheme.Border.subtle)
                                }
                            }
                        }
                    }

                    // MARK: — Hours this session
                    hoursSummaryHeader

                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                            Text("Log Hours This Session")
                                .font(StackTheme.Typography.headline)
                                .foregroundStyle(StackTheme.Accent.indigo)

                            hourStepper(label: "🔵  Theory", value: $theoryStep)
                            hourStepper(label: "🟠  Implementation", value: $implStep)
                            hourStepper(label: "⚗️  Synthesis", value: $synthStep)

                            let sessionTotal = theoryStep + implStep + synthStep
                            if sessionTotal > 0 {
                                Text("Adding \(String(format: "%.1f", sessionTotal)) hrs this session")
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    }

                    // MARK: — Notes
                    StackSectionHeader(title: "Notes")

                    StackCard {
                        TextField("Add notes for this week…", text: Binding(
                            get: { week.notes },
                            set: { week.notes = $0 }
                        ), axis: .vertical)
                        .lineLimit(4, reservesSpace: false)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                    }

                    // MARK: — Complete button
                    Button {
                        if theoryStep + implStep + synthStep > 0 {
                            viewModel.logHours(week: week, theory: theoryStep,
                                               implementation: implStep, synthesis: synthStep)
                        }
                        viewModel.toggleWeekComplete(week)
                        dismiss()
                    } label: {
                        Label(week.isComplete ? "Mark Incomplete" : "Mark Week Complete",
                              systemImage: week.isComplete ? "xmark.circle" : "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                            .font(StackTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(StackTheme.Text.primary)
                            .padding(.vertical, StackTheme.Spacing.md)
                            .background(
                                week.isComplete
                                    ? StackTheme.Background.elevated
                                    : StackTheme.Accent.indigo,
                                in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                            )
                    }
                    .disabled(!week.allTopicsComplete && !week.isComplete)
                    .buttonStyle(.plain)
                    .opacity(!week.allTopicsComplete && !week.isComplete ? 0.5 : 1)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle(week.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if theoryStep + implStep + synthStep > 0 {
                            viewModel.logHours(week: week, theory: theoryStep,
                                               implementation: implStep, synthesis: synthStep)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.large])
    }

    // MARK: — Hours summary header

    private var hoursSummaryHeader: some View {
        HStack {
            StackSectionHeader(title: "Hours")
            Spacer()
            let total = week.totalHours + theoryStep + implStep + synthStep
            Text(String(format: "%.1f / %.0f hr target", total, week.weeklyHourTarget))
                .font(StackTheme.Typography.caption)
                .foregroundStyle(total >= week.weeklyHourTarget ? StackTheme.Accent.green : StackTheme.Text.secondary)
        }
    }

    // MARK: — Topic row

    private func topicRow(_ topic: LearningTopic) -> some View {
        Button {
            viewModel.markTopicComplete(topic)
        } label: {
            HStack(alignment: .top, spacing: StackTheme.Spacing.sm) {
                Text(typeEmoji(topic.topicType))
                    .font(StackTheme.Typography.body)

                VStack(alignment: .leading, spacing: 3) {
                    Text(topic.title)
                        .font(topic.topicType == "milestone"
                              ? StackTheme.Typography.body.bold()
                              : StackTheme.Typography.body)
                        .foregroundStyle(topic.topicType == "milestone"
                                         ? StackTheme.Accent.gold
                                         : StackTheme.Text.primary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: topic.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(topic.isComplete ? StackTheme.Accent.indigo : StackTheme.Text.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(.vertical, StackTheme.Spacing.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: — Hour stepper

    private func hourStepper(label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
                .font(StackTheme.Typography.body)
                .foregroundStyle(StackTheme.Text.primary)
            Spacer()
            Stepper(String(format: "%.1f hr", value.wrappedValue),
                    value: value, in: 0...24, step: 0.5)
                .fixedSize()
        }
    }

    private func typeEmoji(_ type: String) -> String {
        switch type {
        case "implementation": return "🟠"
        case "milestone":      return "🏆"
        default:               return "🔵"
        }
    }
}
