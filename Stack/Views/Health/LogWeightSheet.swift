import SwiftUI

struct LogWeightSheet: View {
    let viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var poundsText: String = ""
    @State private var note: String = ""

    private var poundsValue: Double? { Double(poundsText) }
    private var canSave: Bool { poundsValue != nil && poundsValue! > 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Weight input
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("WEIGHT")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            HStack {
                                TextField("e.g. 175.5", text: $poundsText)
                                    .font(StackTheme.Typography.title)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                Text("lbs")
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

                    // Apple Health button
                    if let hk = viewModel.hkWeight {
                        Button {
                            poundsText = String(format: "%.1f", hk)
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Accent.primary)
                                Text("Use Apple Health value (\(String(format: "%.1f", hk)) lbs)")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Accent.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .background(StackTheme.Accent.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                        }
                        .buttonStyle(.plain)
                    }

                    // Save button
                    Button {
                        if let lbs = poundsValue { viewModel.addWeight(pounds: lbs, note: note) }
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                canSave ? StackTheme.Accent.indigo : StackTheme.Accent.indigo.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSave)

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
            .navigationTitle("Log Weight")
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
        .onAppear {
            if let hk = viewModel.hkWeight { poundsText = String(format: "%.1f", hk) }
        }
    }
}
