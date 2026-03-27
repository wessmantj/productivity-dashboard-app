import SwiftUI
import SwiftData

struct QuotesView: View {
    let viewModel: VisionViewModel
    @State private var showAddQuote = false
    @State private var quoteToDelete: Quote?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var favoriteQuotes: [Quote] { viewModel.quotes.filter { $0.isFavorite } }
    private var allQuotes: [Quote]     { viewModel.quotes.sorted { $0.sortOrder < $1.sortOrder } }
    private var dailyQuoteID: PersistentIdentifier? { viewModel.dailyQuote?.persistentModelID }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.lg) {
                // Add Quote button
                Button { showAddQuote = true } label: {
                    Label("Add Quote", systemImage: "plus.circle.fill")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StackTheme.Spacing.sm + 2)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)

                // Favorites section
                if !favoriteQuotes.isEmpty {
                    StackSectionHeader(title: "Favorites")

                    LazyVGrid(columns: columns, spacing: StackTheme.Spacing.sm) {
                        ForEach(favoriteQuotes) { quote in
                            quoteCard(quote)
                        }
                    }
                }

                // All quotes
                StackSectionHeader(title: "All Quotes")

                LazyVGrid(columns: columns, spacing: StackTheme.Spacing.sm) {
                    ForEach(allQuotes) { quote in
                        quoteCard(quote)
                    }
                }
                .padding(.bottom, StackTheme.Spacing.lg)
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showAddQuote) { AddQuoteSheet(viewModel: viewModel) }
        .alert("Delete quote?", isPresented: Binding(
            get: { quoteToDelete != nil },
            set: { if !$0 { quoteToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let q = quoteToDelete { viewModel.deleteQuote(q) }
                quoteToDelete = nil
            }
            Button("Cancel", role: .cancel) { quoteToDelete = nil }
        }
    }

    // MARK: — Quote card

    private func quoteCard(_ quote: Quote) -> some View {
        ZStack(alignment: .topTrailing) {
            StackCard(elevated: true) {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                    Text("\u{201C}\(quote.text)\u{201D}")
                        .font(StackTheme.Typography.quote)
                        .foregroundStyle(StackTheme.Text.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: StackTheme.Spacing.xs)

                    Text("— \(quote.author)")
                        .font(StackTheme.Typography.caption2)
                        .foregroundStyle(StackTheme.Text.secondary)
                }
            }
            .frame(minHeight: 120)

            // Action buttons: favorite + delete
            VStack(spacing: 0) {
                Button {
                    viewModel.toggleQuoteFavorite(quote)
                } label: {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(quote.isFavorite ? StackTheme.Accent.primary : StackTheme.Text.secondary)
                        .contentTransition(.symbolEffect(.replace))
                        .padding(StackTheme.Spacing.sm + 2)
                }
                .buttonStyle(.plain)

                Button { quoteToDelete = quote } label: {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                        .padding(StackTheme.Spacing.sm + 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: — AddQuoteSheet

struct AddQuoteSheet: View {
    let viewModel: VisionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var author = ""

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty &&
        !author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    StackSectionHeader(title: "Quote")

                    StackCard {
                        TextField("Quote text…", text: $text, axis: .vertical)
                            .lineLimit(4, reservesSpace: false)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                    }

                    StackSectionHeader(title: "Author")

                    StackCard {
                        TextField("Author name", text: $author)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                    }

                    Button {
                        viewModel.addQuote(
                            text: text.trimmingCharacters(in: .whitespaces),
                            author: author.trimmingCharacters(in: .whitespaces)
                        )
                        dismiss()
                    } label: {
                        Text("Add Quote")
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StackTheme.Spacing.md)
                            .background(
                                canSave ? StackTheme.Accent.primary : StackTheme.Accent.primary.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                            )
                    }
                    .disabled(!canSave)
                    .buttonStyle(.plain)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle("Add Quote")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.medium])
    }
}
