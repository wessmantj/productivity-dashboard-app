import SwiftUI

struct LogCardioSheet: View {
    let viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var type:      String = "Run"
    @State private var duration:  Int    = 30
    @State private var distText:  String = ""
    @State private var calText:   String = ""
    @State private var note:      String = ""

    private static let types = ["Run", "Walk", "Bike", "Stairmaster", "Swim", "Other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Activity type picker
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("ACTIVITY")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            Picker("Type", selection: $type) {
                                ForEach(Self.types, id: \.self) { Text($0).tag($0) }
                            }
                            .foregroundStyle(StackTheme.Text.primary)
                        }
                    }

                    // Duration stepper
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("DURATION")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            Stepper("\(duration) minutes", value: $duration, in: 5...180, step: 5)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                        }
                    }

                    // Optional fields
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                            Text("OPTIONAL DETAILS")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            HStack {
                                TextField("Distance", text: $distText)
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                Text("miles")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                            Divider()
                                .background(StackTheme.Border.subtle)
                            HStack {
                                TextField("Calories", text: $calText)
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                Text("kcal")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    }

                    // Note input
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("NOTE (OPTIONAL)")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            TextField("Add a note…", text: $note, axis: .vertical)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                                .lineLimit(3, reservesSpace: false)
                        }
                    }

                    // Save button
                    Button {
                        viewModel.addCardio(
                            type: type,
                            duration: duration,
                            distance: Double(distText) ?? 0,
                            calories: Int(calText) ?? 0,
                            note: note
                        )
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                    }
                    .buttonStyle(.plain)

                    // Cancel button
                    Button { dismiss() } label: {
                        Text("Cancel")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.elevated)
            .navigationTitle("Log Cardio")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(iOS)
            .toolbarBackground(StackTheme.Background.elevated, for: .navigationBar)
            #endif
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.medium, .large])
    }
}
