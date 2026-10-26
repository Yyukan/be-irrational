import CoreData
import SwiftUI

/// Where an occupation was opened from: the list it pages through and the place it lives in.
struct OccupationPage: Hashable {
    let ids: [NSManagedObjectID]
    let index: Int
    let origin: Status

    init(_ ids: [NSManagedObjectID], at index: Int, from origin: Status) {
        self.ids = ids
        self.index = index
        self.origin = origin
    }
}

/// One occupation on the notepad: title, note, progress and how many days it has taken, with the
/// neighbours of its list one swipe (or one arrow) away.
struct OccupationView: View {
    @Environment(Planner.self) private var planner
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    @State private var ids: [NSManagedObjectID]
    @State private var index: Int
    @State private var forward = true
    @State private var editing: Occupation?
    private let origin: Status

    init(page: OccupationPage) {
        _ids = State(initialValue: page.ids)
        _index = State(initialValue: page.index)
        origin = page.origin
    }

    private var current: Occupation? {
        guard ids.indices.contains(index),
            let occupation = try? context.existingObject(with: ids[index]) as? Occupation,
            !occupation.isDeleted
        else { return nil }
        return occupation
    }

    var body: some View {
        DeskPage(title: "Occupation") {
            if let occupation = current {
                OccupationCard(
                    occupation: occupation,
                    progressEnabled: origin == .now || origin == .completed
                )
                .id(occupation.objectID)
                .transition(.push(from: forward ? .trailing : .leading))
                .gesture(
                    DragGesture(minimumDistance: 30).onEnded { drag in
                        guard abs(drag.translation.width) > abs(drag.translation.height) else { return }
                        drag.translation.width < 0 ? step(1) : step(-1)
                    })
            }
        }
        .toolbar {
            if origin != .trash, let occupation = current {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "pencil") { editing = occupation }
                        .accessibilityIdentifier("occupation.edit")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Previous", systemImage: "chevron.left") { step(-1) }
                    .disabled(index <= 0)
                    .accessibilityIdentifier("occupation.previous")
                Button("Next", systemImage: "chevron.right") { step(1) }
                    .disabled(index >= ids.count - 1)
                    .accessibilityIdentifier("occupation.next")
                Spacer()
                if origin != .trash {
                    Button("Trash", systemImage: "trash", role: .destructive, action: trashCurrent)
                        .accessibilityIdentifier("occupation.trash")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(item: $editing) { occupation in
            EditorSheet(heading: "Occupation", title: occupation.title, note: occupation.note ?? "") {
                planner.update(occupation, title: $0, note: $1)
            }
        }
    }

    private func step(_ delta: Int) {
        let target = index + delta
        guard ids.indices.contains(target) else { return }
        forward = delta > 0
        withAnimation(.easeInOut(duration: 0.3)) { index = target }
    }

    private func trashCurrent() {
        guard let occupation = current else { return }
        planner.move(occupation, to: .trash)
        ids.remove(at: index)
        if ids.isEmpty {
            dismiss()
        } else {
            withAnimation { index = min(index, ids.count - 1) }
        }
    }
}

/// The page itself; observes the occupation so edits show at once.
struct OccupationCard: View {
    @ObservedObject var occupation: Occupation
    let progressEnabled: Bool
    @Environment(Planner.self) private var planner
    @State private var progress: Double = 0

    var body: some View {
        List {
            Section {
                Label {
                    Text(occupation.title)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Theme.ink)
                        .accessibilityIdentifier("card.title")
                } icon: {
                    Image(systemName: "tag.fill").foregroundStyle(Theme.brown)
                }
                .listRowBackground(Theme.paper)

                if let note = occupation.note, !note.isEmpty {
                    Label {
                        Text(note).foregroundStyle(Theme.ink)
                    } icon: {
                        Image(systemName: "note.text").foregroundStyle(Theme.brown)
                    }
                    .listRowBackground(Theme.paper)
                }

                HStack(spacing: 14) {
                    DotsRing(fraction: progress / 100, label: "\(Int(progress))%", size: 46)
                    Slider(value: $progress, in: 0...100, step: 5) { editing in
                        if !editing { planner.setProgress(occupation, to: Int(progress)) }
                    }
                    .tint(Theme.brown)
                    .disabled(!progressEnabled)
                    .accessibilityLabel("Progress")
                    .accessibilityIdentifier("card.progress")
                }
                .listRowBackground(Theme.paper)

                HStack(spacing: 14) {
                    let days = occupation.days()
                    DotsRing(fraction: Double(days) / 10, label: "\(days)", size: 46)
                    VStack(alignment: .leading, spacing: 2) {
                        if let date = occupation.date {
                            Text("Since \(date.formatted(date: .complete, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(Theme.ink)
                        }
                        Text(daysLine(days))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .listRowBackground(Theme.paper)
            } header: {
                if let domain = occupation.domain {
                    ScopeHeader(domain: domain)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onAppear { progress = Double(occupation.progress) }
        .onChange(of: occupation.progress) { progress = Double(occupation.progress) }
    }

    private func daysLine(_ days: Int) -> String {
        let count = days == 1 ? "1 day" : "\(days) days"
        return occupation.completedDate == nil ? "\(count) on it" : "Done in \(count)"
    }
}
