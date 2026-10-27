import CoreData
import SwiftUI

/// The Now tab: the scopes of life, each with how many occupations it has on the go.
struct ScopesView: View {
    @Environment(Planner.self) private var planner
    @FetchRequest(fetchRequest: Domain.fetchNow()) private var scopes: FetchedResults<Domain>
    @FetchRequest(fetchRequest: Occupation.fetch(status: .now)) private var active: FetchedResults<Occupation>

    @State private var editMode = EditMode.inactive
    @State private var editing: Domain?
    @State private var addingScope = false
    @State private var showingSuggestions = false
    @State private var pendingMove: PendingMove?
    @State private var pendingDelete: Domain?

    private struct PendingMove: Identifiable {
        let domain: Domain
        let status: Status
        var id: String { "\(domain.objectID)-\(status.rawValue)" }
    }

    var body: some View {
        DeskPage(title: "Now") {
            if scopes.isEmpty {
                emptyState
            } else {
                scopeList
            }
        }
        .environment(\.editMode, $editMode)
        .navigationDestination(for: Domain.self) { ScopeView(domain: $0) }
        .toolbar { toolbar }
        .sheet(isPresented: $addingScope) {
            EditorSheet(heading: "New Scope", title: "", note: "") { planner.addScope(title: $0, note: $1) }
        }
        .sheet(item: $editing) { domain in
            EditorSheet(heading: "Scope", title: domain.title, note: domain.note ?? "") {
                planner.update(domain, title: $0, note: $1)
            }
        }
        .sheet(isPresented: $showingSuggestions) { SuggestionsSheet() }
        .onAppear { if Launch.showsSuggestions { showingSuggestions = true } }
        .modifier(moveDialog)
        .modifier(deleteDialog)
    }

    private var scopeList: some View {
        let counts = Dictionary(grouping: active, by: { $0.domain?.objectID }).mapValues(\.count)
        return List {
            ForEach(scopes) { domain in
                row(domain, count: counts[domain.objectID] ?? 0)
            }
            .onMove { planner.moveScopes(from: $0, to: $1) }
            .onDelete { offsets in pendingDelete = offsets.first.map { scopes[$0] } }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("scopes.list")
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if !scopes.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                Button(editMode.isEditing ? "Done" : "Edit") {
                    withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                }
                .accessibilityIdentifier("scopes.edit")
            }
        }
        ToolbarItem(placement: .topBarTrailing) { addMenu }
    }

    private var moveDialog: ItemDialog<PendingMove> {
        ItemDialog(
            item: $pendingMove, title: { moveTitle($0.status) },
            actions: { move in
                AnyView(
                    Button(moveTitle(move.status), role: move.status == .trash ? .destructive : nil) {
                        planner.moveAll(in: move.domain, to: move.status)
                    })
            },
            message: { "Every occupation of “\($0.domain.title)” on the Now list." })
    }

    private var deleteDialog: ItemDialog<Domain> {
        ItemDialog(
            item: $pendingDelete, title: { _ in "Delete Scope" },
            actions: { domain in
                AnyView(Button("Delete Scope", role: .destructive) { planner.delete(domain) })
            },
            message: {
                "“\($0.title)” and all its occupations, including those in Someday, Completed and Trash."
            })
    }

    private func row(_ domain: Domain, count: Int) -> some View {
        NavigationLink(value: domain) {
            HStack(spacing: 12) {
                DotsRing(fraction: Double(count) / 10, label: "\(count)")
                VStack(alignment: .leading, spacing: 2) {
                    Text(domain.title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Theme.ink)
                    if let note = domain.note, !note.isEmpty {
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .listRowBackground(Theme.paper)
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(count) on the go")
        .accessibilityIdentifier("scope.\(domain.title)")
        .swipeActions(edge: .leading) {
            Button("Edit", systemImage: "pencil") { editing = domain }
                .tint(Theme.brown)
        }
        .swipeActions(edge: .trailing) {
            if count > 0 {
                Button("Trash All", systemImage: Status.trash.symbol) {
                    pendingMove = PendingMove(domain: domain, status: .trash)
                }
                .tint(.red)
                Button("Complete All", systemImage: Status.completed.symbol) {
                    pendingMove = PendingMove(domain: domain, status: .completed)
                }
                .tint(.green)
                Button("Someday All", systemImage: Status.someday.symbol) {
                    pendingMove = PendingMove(domain: domain, status: .someday)
                }
                .tint(.orange)
            }
        }
    }

    private var addMenu: some View {
        Menu {
            Button("New Scope", systemImage: "square.and.pencil") { addingScope = true }
            Button("Suggested Scopes", systemImage: "list.bullet") { showingSuggestions = true }
        } label: {
            Label("Add", systemImage: "plus")
        }
        .accessibilityIdentifier("scopes.add")
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("What matters to you?", systemImage: "lightbulb.max")
        } description: {
            Text("Start with a scope of your life, then fill it with the things you would do now.")
        } actions: {
            Button("Pick from Suggestions") { showingSuggestions = true }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("empty.suggestions")
            Button("Write My Own") { addingScope = true }
                .accessibilityIdentifier("empty.new")
        }
    }

    private func moveTitle(_ status: Status) -> String {
        switch status {
        case .trash: "Trash All Occupations"
        case .completed: "Move All to Completed"
        case .someday: "Move All to Someday"
        case .now: "Move All to Now"
        }
    }
}

/// The 2011 ready-made scopes; the ones already on the list carry a check mark.
struct SuggestionsSheet: View {
    @Environment(Planner.self) private var planner
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(fetchRequest: Domain.fetchNow()) private var scopes: FetchedResults<Domain>

    var body: some View {
        NavigationStack {
            List(SuggestedScope.all, id: \.self) { suggestion in
                let added = scopes.contains { $0.text == suggestion.title && $0.note == suggestion.note }
                Button {
                    planner.addScope(title: suggestion.title, note: suggestion.note)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title).foregroundStyle(Theme.ink)
                            Text(suggestion.note).font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if added {
                            Image(systemName: "checkmark").foregroundStyle(Theme.brown)
                        }
                    }
                }
                .disabled(added)
                .accessibilityIdentifier("suggestion.\(suggestion.title)")
            }
            .navigationTitle("Suggested Scopes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("suggestions.done")
                }
            }
        }
    }
}

/// A binding that is true while the optional holds something, for dialogs driven by an item.
@MainActor
func isPresent<T>(_ item: Binding<T?>) -> Binding<Bool> {
    Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
}

/// A confirmation dialog driven by an optional item, so the body above stays small enough for the
/// type checker.
struct ItemDialog<Item>: ViewModifier {
    @Binding var item: Item?
    let title: (Item) -> String
    let actions: (Item) -> AnyView
    let message: (Item) -> String

    func body(content: Content) -> some View {
        content.confirmationDialog(
            item.map(title) ?? "", isPresented: isPresent($item), titleVisibility: .visible, presenting: item
        ) { item in
            actions(item)
        } message: { item in
            Text(message(item))
        }
    }
}
