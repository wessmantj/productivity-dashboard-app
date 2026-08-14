import SwiftUI

struct StackProgressBar: View {
    let value: Double          // 0.0 – 1.0
    var color: Color = StackTheme.Accent.primary
    var height: CGFloat = 4

    @State private var animatedValue: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(StackTheme.Background.elevated)
                    .frame(height: height)
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * max(0, min(1, animatedValue)), height: height)
                    .shadow(color: color.opacity(0.5), radius: height * 0.8)
                    .animation(.easeOut(duration: 0.6), value: animatedValue)
            }
        }
        .frame(height: height)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animatedValue = max(0, min(1, value))
            }
        }
        .onChange(of: value) { _, newValue in
            animatedValue = max(0, min(1, newValue))
        }
    }
}
