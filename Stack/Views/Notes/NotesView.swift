import SwiftUI

struct NotesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No notes yet",
                systemImage: "note.text",
                description: Text("Create your first note.")
            )
            .navigationTitle("Notes")
        }
    }
}

#Preview {
    NotesView()
}
