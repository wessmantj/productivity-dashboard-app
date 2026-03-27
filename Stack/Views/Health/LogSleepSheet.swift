import SwiftUI

struct LogSleepSheet: View {
    let viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var hours: Double = 7.5
    @State private var quality: Int  = 3
    @State private var note: String  = ""

    private static let hourOptions: [Double] = stride(from: 4.0, through: 12.0, by: 0.5).map { $0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Duration picker
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("DURATION")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            Picker("Hours", selection: $hours) {
                                ForEach(Self.hourOptions, id: \.self) { h in
                                    Text(String(format: "%.1f hrs", h))
                                        .foregroundStyle(StackTheme.Text.primary)
                                        .tag(h)
                                }
                            }
                            #if os(iOS)
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                            #endif
                        }
                    }

                    // Quality stars
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("QUALITY")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.tertiary)
                            HStack(spacing: StackTheme.Spacing.sm) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        quality = star
                                    } label: {
                                        Image(systemName: star <= quality ? "star.fill" : "star")
                                            .font(.title2)
                                            .foregroundStyle(star <= quality ? StackTheme.Accent.gold : StackTheme.Text.tertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                                Text(qualityLabel)
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
                    if let hk = viewModel.hkSleep {
                        Button {
                            hours = (stride(from: 4.0, through: 12.0, by: 0.5)
                                .min(by: { abs($0 - hk) < abs($1 - hk) }) ?? hk)
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Accent.red)
                                Text("Use Apple Health value (\(String(format: "%.1f", hk)) hrs)")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Accent.red)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .background(StackTheme.Accent.red.opacity(0.12), in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                        }
                        .buttonStyle(.plain)
                    }

                    // Save button
                    Button {
                        viewModel.addSleep(hours: hours, quality: quality, note: note)
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
            .navigationTitle("Log Sleep")
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
            if let hk = viewModel.hkSleep {
                hours = stride(from: 4.0, through: 12.0, by: 0.5)
                    .min(by: { abs($0 - hk) < abs($1 - hk) }) ?? 7.5
            }
        }
    }

    private var qualityLabel: String {
        switch quality {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent"
        default: return ""
        }
    }
}
