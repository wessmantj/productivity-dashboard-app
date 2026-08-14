import SwiftUI
import HealthKit

// MARK: - Container

struct OnboardingView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            StackTheme.Background.base.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button — top right, hidden on the last page
                HStack {
                    Spacer()
                    Button("Skip", action: finish)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .opacity(currentPage < 2 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
                .padding(.horizontal, StackTheme.Spacing.xl)
                .padding(.top, StackTheme.Spacing.md)
                .frame(height: 52)

                // Page content — swipeable
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    FeaturesPage()
                        .tag(1)
                    SetupPage()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .tint(StackTheme.Accent.primary)

                // Bottom action button
                bottomButton
                    .padding(.horizontal, StackTheme.Spacing.xl)
                    .padding(.bottom, 40)
                    .frame(height: 80, alignment: .top)
            }
        }
    }

    @ViewBuilder
    private var bottomButton: some View {
        if currentPage < 2 {
            HStack {
                Spacer()
                Button {
                    withAnimation { currentPage = min(currentPage + 1, 2) }
                } label: {
                    Text("Next")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(StackTheme.Accent.primary)
                        .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
            }
        } else {
            Button(action: finish) {
                Text("Get Started")
                    .font(StackTheme.Typography.body.bold())
                    .foregroundStyle(StackTheme.Text.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StackTheme.Accent.primary)
                    .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
            }
        }
    }

    private func finish() {
        hasCompletedOnboarding = true
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("StackLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.lg))
                .scaleEffect(appeared ? 1.0 : 0.8)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.spring(duration: 0.6), value: appeared)
                .onAppear { appeared = true }

            Spacer().frame(height: 36)

            VStack(spacing: 14) {
                Text("Welcome to Stack")
                    .font(StackTheme.Typography.title)
                    .foregroundStyle(StackTheme.Text.primary)
                    .multilineTextAlignment(.center)

                Text("Your personal command center. Built around who you're becoming.")
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, StackTheme.Spacing.xl)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 2: Features

private struct FeaturesPage: View {

    @State private var appeared = false

    private let features: [(icon: String, title: String, desc: String)] = [
        ("checklist",            "Protocol", "Your full daily system — morning to sleep — checked off every day"),
        ("dumbbell.fill",        "Fitness",  "Weekly workout split, supplements, body, sleep, and cardio tracking"),
        ("checkmark.circle.fill", "Tasks",    "A fast, frictionless list for everything else on your plate"),
        ("chart.bar.fill",       "Progress", "Streaks and year-long heatmaps that show the work adding up"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Everything in one place")
                .font(StackTheme.Typography.title)
                .foregroundStyle(StackTheme.Text.primary)
                .padding(.horizontal, StackTheme.Spacing.xl)

            Spacer().frame(height: StackTheme.Spacing.xl)

            VStack(spacing: StackTheme.Spacing.lg) {
                ForEach(Array(features.enumerated()), id: \.offset) { i, f in
                    HStack(spacing: StackTheme.Spacing.md) {
                        Image(systemName: f.icon)
                            .font(.title2)
                            .foregroundStyle(StackTheme.Accent.primary)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                            Text(f.title)
                                .font(StackTheme.Typography.headline)
                                .foregroundStyle(StackTheme.Text.primary)
                            Text(f.desc)
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, StackTheme.Spacing.xl)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.1), value: appeared)
                }
            }

            Spacer()
            Spacer()
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Page 3: Name + Permissions

private struct SetupPage: View {

    @AppStorage("userName") private var userName = ""
    @State private var healthGranted = false
    @State private var notifGranted  = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 14) {
                Text("Make it yours")
                    .font(StackTheme.Typography.title)
                    .foregroundStyle(StackTheme.Text.primary)

                Text("Stack works best with your name, health data, and notifications.")
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, StackTheme.Spacing.xl)

            Spacer().frame(height: 28)

            VStack(spacing: StackTheme.Spacing.md) {
                StackCard {
                    HStack(spacing: StackTheme.Spacing.md) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(StackTheme.Accent.primary)
                            .frame(width: 32)
                        TextField("Your name", text: $userName)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                            .focused($nameFocused)
                            .onSubmit { nameFocused = false }
                    }
                }

                PermissionRow(
                    icon: "heart.fill",
                    iconColor: StackTheme.Accent.negative,
                    title: "Apple Health",
                    description: "Pulls your weight, sleep, and activity automatically",
                    isGranted: healthGranted,
                    action: requestHealth
                )
                PermissionRow(
                    icon: "bell.fill",
                    iconColor: StackTheme.Accent.primary,
                    title: "Notifications",
                    description: "Reminds you of your protocol and daily check-ins",
                    isGranted: notifGranted,
                    action: requestNotifications
                )
            }
            .padding(.horizontal, StackTheme.Spacing.xl)

            Spacer()
            Spacer()
        }
    }

    private func requestHealth() {
        guard HKHealthStore.isHealthDataAvailable() else { healthGranted = true; return }
        let store = HKHealthStore()
        store.requestAuthorization(toShare: [], read: HealthKitService.readTypes) { _, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "healthKitAuthorized")
                healthGranted = true
            }
        }
    }

    private func requestNotifications() {
        Task {
            let granted = await NotificationService.requestAuthorization()
            notifGranted = granted
            if granted { NotificationService.syncFromPreferences() }
        }
    }
}

// MARK: - Permission Row

private struct PermissionRow: View {

    let icon:        String
    let iconColor:   Color
    let title:       String
    let description: String
    let isGranted:   Bool
    let action:      () -> Void

    var body: some View {
        StackCard {
            HStack(spacing: StackTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                    Text(title)
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Text.primary)
                    Text(description)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isGranted {
                    StackBadge(text: "✓", color: StackTheme.Accent.positive, style: .filled)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button("Allow", action: action)
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .padding(.horizontal, StackTheme.Spacing.md)
                        .padding(.vertical, StackTheme.Spacing.sm)
                        .background(StackTheme.Accent.primary)
                        .clipShape(RoundedRectangle(cornerRadius: StackTheme.Radius.sm))
                }
            }
            .animation(.spring(duration: 0.3), value: isGranted)
        }
    }
}

#Preview {
    OnboardingView()
}
