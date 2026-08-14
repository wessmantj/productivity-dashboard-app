import SwiftUI

// MARK: - StackRing — animated circular gauge (Whoop-style)

struct StackRing<Center: View>: View {
    let value: Double                 // 0.0 – 1.0
    var color: Color = StackTheme.Accent.primary
    var lineWidth: CGFloat = 14
    var size: CGFloat = 200
    var glow: Bool = true
    @ViewBuilder var center: () -> Center

    @State private var animatedValue: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(StackTheme.Background.elevated, lineWidth: lineWidth)

            // Fill — only drawn once there's progress, so 0% shows a clean track
            if animatedValue > 0.001 {
                Circle()
                    .trim(from: 0, to: min(1, animatedValue))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.55), color]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * min(1, animatedValue))
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: glow ? color.opacity(0.45) : .clear, radius: lineWidth * 0.6)
            }

            center()
        }
        .frame(width: size, height: size)
        .padding(lineWidth / 2)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - CountUpNumber — numeral that counts up on appear (Whoop-style)

struct CountUpNumber: View {
    let value: Int
    var suffix: String = ""
    var font: Font = StackTheme.Typography.hero
    var color: Color = StackTheme.Text.primary

    @State private var displayed: Int = 0

    var body: some View {
        Text("\(displayed)\(suffix)")
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText(value: Double(displayed)))
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    displayed = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: 0.6)) {
                    displayed = newValue
                }
            }
    }
}

// MARK: - StackLabel — uppercase letter-spaced micro-label

struct StackLabel: View {
    let text: String
    var color: Color = StackTheme.Text.secondary
    var tracking: CGFloat = StackTheme.Tracking.label

    init(_ text: String, color: Color = StackTheme.Text.secondary,
         tracking: CGFloat = StackTheme.Tracking.label) {
        self.text = text
        self.color = color
        self.tracking = tracking
    }

    var body: some View {
        Text(text.uppercased())
            .font(StackTheme.Typography.label)
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

// MARK: - StackSegmentTabs — Whoop-style uppercase tabs with sliding underline

struct StackSegmentTabs<T: Hashable>: View {
    let items: [(value: T, label: String)]
    @Binding var selection: T

    @Namespace private var underline

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: StackTheme.Spacing.lg) {
                ForEach(items, id: \.value) { item in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selection = item.value
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        VStack(spacing: 6) {
                            Text(item.label.uppercased())
                                .font(StackTheme.Typography.label)
                                .tracking(StackTheme.Tracking.label)
                                .foregroundStyle(
                                    selection == item.value
                                        ? StackTheme.Text.primary
                                        : StackTheme.Text.tertiary
                                )

                            Group {
                                if selection == item.value {
                                    Capsule()
                                        .fill(StackTheme.Accent.primary)
                                        .matchedGeometryEffect(id: "underline", in: underline)
                                } else {
                                    Capsule().fill(.clear)
                                }
                            }
                            .frame(height: 3)
                        }
                        .fixedSize()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, StackTheme.Spacing.md)
        }
    }
}
