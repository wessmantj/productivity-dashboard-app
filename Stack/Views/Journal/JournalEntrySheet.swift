import SwiftUI

struct JournalEntrySheet: View {
    let viewModel: JournalViewModel
    let existing: JournalEntry?
    @Environment(\.dismiss) private var dismiss

    @State private var body_: String = ""
    @State private var mood: Int = 3
    @State private var tagsText: String = ""
    @FocusState private var editorFocused: Bool

    private static let moods: [(Int, String)] = [(1,"😔"),(2,"😕"),(3,"😐"),(4,"🙂"),(5,"😄")]

    private var wordCount: Int { body_.split(whereSeparator: \.isWhitespace).count }
    private var parsedTags: [String] {
        tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mood row
                HStack(spacing: 0) {
                    ForEach(Self.moods, id: \.0) { val, emoji in
                        Button {
                            withAnimation(.spring(response: 0.3)) { mood = val }
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        } label: {
                            ZStack {
                                if mood == val {
                                    RoundedRectangle(cornerRadius: StackTheme.Radius.sm)
                                        .fill(StackTheme.Background.elevated)
                                        .padding(4)
                                }
                                Text(emoji)
                                    .font(.system(size: mood == val ? 36 : 26))
                                    .scaleEffect(mood == val ? 1.2 : 1.0)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .animation(.spring(response: 0.3), value: mood)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(StackTheme.Background.elevated)

                Divider()
                    .background(StackTheme.Border.subtle)

                // Text editor
                ZStack(alignment: .topLeading) {
                    if body_.isEmpty {
                        Text("Write about today…")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.tertiary)
                            .padding(.horizontal, StackTheme.Spacing.md)
                            .padding(.top, 12)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $body_)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .scrollContentBackground(.hidden)
                        .background(StackTheme.Background.elevated)
                        .lineSpacing(4)
                        .focused($editorFocused)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                }
                .background(StackTheme.Background.elevated)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()
                    .background(StackTheme.Border.subtle)

                // Tags + word count bar
                HStack(spacing: StackTheme.Spacing.sm) {
                    Image(systemName: "tag")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                    TextField("Tags, comma separated", text: $tagsText)
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.primary)

                    Spacer()
                    Text("\(wordCount) words")
                        .font(StackTheme.Typography.caption2)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, StackTheme.Spacing.sm)
                .background(StackTheme.Background.elevated)

                // Tag pills
                if !parsedTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: StackTheme.Spacing.xs) {
                            ForEach(parsedTags, id: \.self) { tag in
                                StackBadge(text: "#\(tag)", color: StackTheme.Accent.primary, style: .subtle)
                            }
                        }
                        .padding(.horizontal, StackTheme.Spacing.md)
                        .padding(.vertical, StackTheme.Spacing.xs)
                    }
                    .background(StackTheme.Background.elevated)
                }
            }
            .navigationTitle(existing == nil ? "New Entry" : "Edit Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEntry(body: body_, mood: mood, tags: parsedTags)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.large])
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let e = existing {
                body_ = e.body
                mood = e.mood
                tagsText = e.tags.joined(separator: ", ")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                editorFocused = true
            }
        }
    }
}
