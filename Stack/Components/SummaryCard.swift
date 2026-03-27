import SwiftUI

struct SummaryCard: View {

    let title: String
    let icon: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(accentColor)
                Spacer()
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text("—")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SummaryCard(title: "Tasks", icon: "checkmark.circle", accentColor: .blue)
        .frame(width: 180)
        .padding()
}
