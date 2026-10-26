import CoreData
import SwiftUI

/// Someday, Completed and Trash: every occupation in that place, grouped by scope.
struct ShelfView: View {
    let status: Status
    @Environment(Planner.self) private var planner
    @FetchRequest private var occupations: FetchedResults<Occupation>
    @State private var confirmingEmpty = false

    init(status: Status) {
        self.status = status
        _occupations = FetchRequest(fetchRequest: Occupation.fetch(status: status))
    }

    var body: some View {
        let ids = occupations.map(\.objectID)
        let groups = grouped()
        DeskPage(title: status.title) {
            if occupations.isEmpty {
                ContentUnavailableView(emptyTitle, systemImage: status.symbol, description: Text(emptyText))
            } else {
                List {
                    ForEach(groups, id: \.title) { group in
                        Section {
                            ForEach(group.items, id: \.objectID) { occupation in
                                NavigationLink(
                                    value: OccupationPage(ids, at: ids.firstIndex(of: occupation.objectID) ?? 0, from: status)
                                ) {
                                    OccupationRow(occupation: occupation, showsProgress: status == .completed)
                                }
                                .listRowBackground(Theme.paper)
                                .swipeActions(edge: .trailing) {
                                    MoveButtons(occupation: occupation, except: status)
                                }
                            }
                        } header: {
                            Text(group.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                                .textCase(nil)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .accessibilityIdentifier("\(status.title.lowercased()).list")
            }
        }
        .toolbar {
            if status == .trash, !occupations.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Empty") { confirmingEmpty = true }
                        .accessibilityIdentifier("trash.empty")
                }
            }
        }
        .confirmationDialog("Empty Trash", isPresented: $confirmingEmpty, titleVisibility: .visible) {
            Button("Empty Trash", role: .destructive) { withAnimation { planner.emptyTrash() } }
        } message: {
            Text("The occupations in the Trash are deleted for good.")
        }
    }

    private func grouped() -> [(title: String, items: [Occupation])] {
        var groups: [(title: String, items: [Occupation])] = []
        for occupation in occupations {
            let title = occupation.domain?.title ?? ""
            if groups.last?.title == title {
                groups[groups.count - 1].items.append(occupation)
            } else {
                groups.append((title, [occupation]))
            }
        }
        return groups
    }

    private var emptyTitle: String {
        switch status {
        case .someday: "Nothing for someday"
        case .completed: "Nothing completed yet"
        default: "Trash is empty"
        }
    }

    private var emptyText: String {
        switch status {
        case .someday: "Swipe an occupation to put it aside for later."
        case .completed: "Swipe an occupation when it is done; it lands here."
        default: "Trashed occupations wait here until you empty it."
        }
    }
}
