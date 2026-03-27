import SwiftUI
import SwiftData
#if os(iOS)
import HealthKit
import UserNotifications
#endif

struct SettingsView: View {

    // MARK: - Stored preferences

    @AppStorage("userName")                 private var userName:                String = ""
    @AppStorage("hasCompletedOnboarding")   private var hasCompletedOnboarding:  Bool   = false
    @AppStorage("protocolReminderEnabled")  private var protocolReminderEnabled: Bool   = false
    @AppStorage("protocolReminderSecs")     private var protocolReminderSecs:     Double = 8 * 3600
    @AppStorage("eveningCheckInEnabled")    private var eveningCheckInEnabled:   Bool   = false
    @AppStorage("eveningCheckInSecs")       private var eveningCheckInSecs:      Double = 21 * 3600
    @AppStorage("taskRemindersEnabled")     private var taskRemindersEnabled:    Bool   = false

    // MARK: - Local state

    @State private var showResetProtocolAlert   = false
    @State private var showResetOnboardingAlert = false
    @State private var healthAuthorized         = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss

    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    // MARK: - Time-picker bindings (seconds-from-midnight ↔ Date)

    private var protocolReminderDate: Binding<Date> {
        secsToDateBinding($protocolReminderSecs)
    }

    private var eveningCheckInDate: Binding<Date> {
        secsToDateBinding($eveningCheckInSecs)
    }

    private func secsToDateBinding(_ storage: Binding<Double>) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.startOfDay(for: Date()).addingTimeInterval(storage.wrappedValue)
            },
            set: {
                storage.wrappedValue = $0.timeIntervalSince(Calendar.current.startOfDay(for: $0))
            }
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.lg) {
                    profileSection
                    notificationsSection
                    healthSection
                    dataSection
                    appSection
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { checkHealthAuth() }
        .alert("Reset Daily Protocol?", isPresented: $showResetProtocolAlert) {
            Button("Reset", role: .destructive) { resetDailyProtocol() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Clears today's completed items. Past days are not affected.")
        }
        .alert("Reset Onboarding?", isPresented: $showResetOnboardingAlert) {
            Button("Reset", role: .destructive) {
                hasCompletedOnboarding = false
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The intro screens will appear again on next launch.")
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Profile")

            StackCard {
                HStack(spacing: StackTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(StackTheme.Accent.indigo)
                            .frame(width: 48, height: 48)
                        Text(initials.isEmpty ? "?" : initials)
                            .font(StackTheme.Typography.headline)
                            .foregroundStyle(StackTheme.Text.primary)
                    }
                    TextField("Your name", text: $userName)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                }
            }
        }
    }

    private var initials: String {
        userName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map { String($0).uppercased() } }
            .joined()
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Notifications")

            StackCard {
                VStack(spacing: StackTheme.Spacing.sm) {
                    #if os(iOS)
                    Toggle("Daily protocol reminder", isOn: $protocolReminderEnabled)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .tint(StackTheme.Accent.indigo)
                    if protocolReminderEnabled {
                        Divider().background(StackTheme.Border.subtle)
                        DatePicker("Time",
                                   selection: protocolReminderDate,
                                   displayedComponents: .hourAndMinute)
                    }
                    Divider().background(StackTheme.Border.subtle)
                    Toggle("Evening check-in", isOn: $eveningCheckInEnabled)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .tint(StackTheme.Accent.indigo)
                    if eveningCheckInEnabled {
                        Divider().background(StackTheme.Border.subtle)
                        DatePicker("Time",
                                   selection: eveningCheckInDate,
                                   displayedComponents: .hourAndMinute)
                    }
                    Divider().background(StackTheme.Border.subtle)
                    Toggle("Task due date reminders", isOn: $taskRemindersEnabled)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .tint(StackTheme.Accent.indigo)
                    #else
                    Text("Notifications are available on iPhone only.")
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.secondary)
                    #endif
                }
            }
        }
    }

    // MARK: - Health

    private var healthSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Health")

            StackCard {
                #if os(iOS)
                VStack(spacing: StackTheme.Spacing.sm) {
                    HStack {
                        Label("Apple Health", systemImage: "heart.fill")
                            .foregroundStyle(StackTheme.Accent.primary)
                        Spacer()
                        HStack(spacing: 5) {
                            Circle()
                                .fill(healthAuthorized ? StackTheme.Accent.green : StackTheme.Accent.red)
                                .frame(width: 8, height: 8)
                            Text(healthAuthorized ? "Connected" : "Not connected")
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    }
                    if !healthAuthorized {
                        Divider().background(StackTheme.Border.subtle)
                        Button("Re-authorize HealthKit") { requestHealthAuth() }
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Accent.indigo)
                    }
                }
                #else
                Text("Health data is available on iPhone only.")
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.secondary)
                #endif
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Data")

            StackCard {
                VStack(spacing: StackTheme.Spacing.sm) {
                    ShareLink(
                        item: journalExportText,
                        subject: Text("Stack Journal Export"),
                        message: Text("My Stack journal entries")
                    ) {
                        Label("Export Journal Entries", systemImage: "square.and.arrow.up")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Divider().background(StackTheme.Border.subtle)

                    Button {
                        showResetProtocolAlert = true
                    } label: {
                        Label("Reset Daily Protocol", systemImage: "arrow.clockwise")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Accent.warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Divider().background(StackTheme.Border.subtle)

                    Button {
                        showResetOnboardingAlert = true
                    } label: {
                        Label("Reset Onboarding", systemImage: "sparkles")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Accent.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - App

    private var appSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "App")

            StackCard {
                VStack(spacing: StackTheme.Spacing.sm) {
                    HStack {
                        Text("Version")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                        Spacer()
                        Text(appVersion)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }

                    Divider().background(StackTheme.Border.subtle)

                    Link(destination: URL(string: "https://apps.apple.com/app/idXXXXXXXXXX")!) {
                        Label("Rate Stack", systemImage: "star")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            Text("Built by wessmantj")
                .font(StackTheme.Typography.caption)
                .foregroundStyle(StackTheme.Text.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, StackTheme.Spacing.xs)
        }
    }

    // MARK: - Helpers

    private var journalExportText: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        fmt.timeStyle = .none
        var lines = ["Stack Journal Export", "Exported \(fmt.string(from: Date()))", ""]
        for entry in journalEntries {
            lines.append("--- \(fmt.string(from: entry.date)) ---")
            lines.append(entry.body)
            if !entry.tags.isEmpty {
                lines.append("Tags: \(entry.tags.joined(separator: ", "))")
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func resetDailyProtocol() {
        let key = {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
            return f.string(from: Date())
        }()
        let desc = FetchDescriptor<DailyProtocol>(
            predicate: #Predicate<DailyProtocol> { $0.date == key }
        )
        if let record = try? modelContext.fetch(desc).first {
            record.completedItems = []
        }
    }

    private func checkHealthAuth() {
        #if os(iOS)
        healthAuthorized = UserDefaults.standard.bool(forKey: "healthKitAuthorized")
        #endif
    }

    private func requestHealthAuth() {
        #if os(iOS)
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]
        HKHealthStore().requestAuthorization(toShare: [], read: types) { _, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "healthKitAuthorized")
                self.healthAuthorized = true
            }
        }
        #endif
    }
}

#Preview {
    SettingsView()
}
