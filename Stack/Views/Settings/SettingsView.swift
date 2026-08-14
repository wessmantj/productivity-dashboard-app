import SwiftUI
import SwiftData
import HealthKit

struct SettingsView: View {

    // MARK: - Stored preferences

    @AppStorage("userName")                 private var userName:                String = ""
    @AppStorage("hasCompletedOnboarding")   private var hasCompletedOnboarding:  Bool   = false
    @AppStorage("protocolReminderEnabled")  private var protocolReminderEnabled: Bool   = false
    @AppStorage("protocolReminderSecs")     private var protocolReminderSecs:    Double = 8 * 3600
    @AppStorage("eveningCheckInEnabled")    private var eveningCheckInEnabled:   Bool   = false
    @AppStorage("eveningCheckInSecs")       private var eveningCheckInSecs:      Double = 21 * 3600

    // MARK: - Local state

    @State private var showResetProtocolAlert   = false
    @State private var showResetOnboardingAlert = false
    @State private var healthAuthorized         = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { checkHealthAuth() }
        .onChange(of: protocolReminderEnabled) { _, enabled in
            updateProtocolReminder(enabled: enabled)
        }
        .onChange(of: protocolReminderSecs) { _, _ in
            updateProtocolReminder(enabled: protocolReminderEnabled)
        }
        .onChange(of: eveningCheckInEnabled) { _, enabled in
            updateEveningCheckIn(enabled: enabled)
        }
        .onChange(of: eveningCheckInSecs) { _, _ in
            updateEveningCheckIn(enabled: eveningCheckInEnabled)
        }
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
                            .fill(StackTheme.Accent.primary)
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
                    Toggle("Daily protocol reminder", isOn: $protocolReminderEnabled)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .tint(StackTheme.Accent.primary)
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
                        .tint(StackTheme.Accent.primary)
                    if eveningCheckInEnabled {
                        Divider().background(StackTheme.Border.subtle)
                        DatePicker("Time",
                                   selection: eveningCheckInDate,
                                   displayedComponents: .hourAndMinute)
                    }
                }
            }
        }
    }

    // MARK: - Health

    private var healthSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Health")

            StackCard {
                VStack(spacing: StackTheme.Spacing.sm) {
                    HStack {
                        Label("Apple Health", systemImage: "heart.fill")
                            .foregroundStyle(StackTheme.Accent.primary)
                        Spacer()
                        HStack(spacing: 5) {
                            Circle()
                                .fill(healthAuthorized ? StackTheme.Accent.positive : StackTheme.Accent.negative)
                                .frame(width: 8, height: 8)
                            Text(healthAuthorized ? "Connected" : "Not connected")
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    }
                    if !healthAuthorized {
                        Divider().background(StackTheme.Border.subtle)
                        Button("Connect Apple Health") { requestHealthAuth() }
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Accent.primary)
                    }
                }
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: "Data")

            StackCard {
                VStack(spacing: StackTheme.Spacing.sm) {
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
                            .foregroundStyle(StackTheme.Accent.negative)
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
                HStack {
                    Text("Version")
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                    Spacer()
                    Text(appVersion)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.secondary)
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

    private func updateProtocolReminder(enabled: Bool) {
        Task {
            if enabled { _ = await NotificationService.requestAuthorization() }
            NotificationService.updateProtocolReminder(
                enabled: enabled,
                secondsFromMidnight: protocolReminderSecs
            )
        }
    }

    private func updateEveningCheckIn(enabled: Bool) {
        Task {
            if enabled { _ = await NotificationService.requestAuthorization() }
            NotificationService.updateEveningCheckIn(
                enabled: enabled,
                secondsFromMidnight: eveningCheckInSecs
            )
        }
    }

    private func resetDailyProtocol() {
        let today = Weekday.today
        let desc = FetchDescriptor<ScheduleBlock>(
            predicate: #Predicate<ScheduleBlock> { $0.dayOfWeek == today }
        )
        if let blocks = try? modelContext.fetch(desc) {
            for block in blocks {
                block.lastCompletedDate = nil
                for item in block.items {
                    item.lastCompletedDate = nil
                }
            }
        }
        DayRecordService.updateProtocol(ratio: 0, for: Date().dateKey, in: modelContext)
        try? modelContext.save()
    }

    private func checkHealthAuth() {
        healthAuthorized = UserDefaults.standard.bool(forKey: "healthKitAuthorized")
    }

    private func requestHealthAuth() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        HKHealthStore().requestAuthorization(toShare: [], read: HealthKitService.readTypes) { _, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "healthKitAuthorized")
                self.healthAuthorized = true
            }
        }
    }
}

#Preview {
    SettingsView()
}
