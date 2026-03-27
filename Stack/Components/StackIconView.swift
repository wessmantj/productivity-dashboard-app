import SwiftUI

/// The Stack brand mark: three horizontal bars representing layered progress.
/// Reused in the app icon generator and onboarding welcome screen.
struct StackIconView: View {

    let size: CGFloat

    // Top → bottom: indigo, purple, gold
    private let barColors: [Color] = [
        Color(hex: "#6366f1"),
        Color(hex: "#8b5cf6"),
        Color(hex: "#f59e0b"),
    ]

    // Top bar is shortest; bottom is longest
    private let widthRatios: [CGFloat] = [0.48, 0.63, 0.78]

    private var barHeight: CGFloat { size * 0.09 }
    private var gap: CGFloat       { size * 0.055 }
    private var corner: CGFloat    { barHeight / 2 }

    var body: some View {
        ZStack {
            Color(hex: "#080810")

            // Subtle indigo radial glow
            RadialGradient(
                colors: [Color(hex: "#6366f1").opacity(0.35), .clear],
                center: .center,
                startRadius: 0,
                endRadius: size * 0.38
            )

            // Bars
            VStack(spacing: gap) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(barColors[i])
                        .frame(width: size * widthRatios[i], height: barHeight)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    StackIconView(size: 200)
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
        .padding()
}
