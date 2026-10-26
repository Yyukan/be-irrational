import CoreData
import SwiftUI

/// "Now I would": the occupations of one scope that are on the go, with their progress.
struct ScopeView: View {
    @ObservedObject var domain: Domain
    @Environment(Planner.self) private var planner
    @FetchRequest private var occupations: FetchedResults<Occupation>

    @State private var editMode = EditMode.inactive
    @State private var adding = false
    @State private var editing: Occupation?

    init(domain: Domain) {
        self.domain = domain
        _occupations = FetchRequest(fetchRequest: Occupation.fetch(in: domain, status: .now))
    }

    var body: some View {
        DeskPage(title: "Now I would") {
            List {
                Section {
                    ForEach(Array(occupations.enumerated()), id: \.element.objectID) { index, occupation in
                        NavigationLink(value: OccupationPage(occupations.map(\.objectID), at: index, from: .now)) {
                            OccupationRow(occupation: occupation, showsProgress: true)
                        }
                        .listRowBackground(Theme.paper)
                        .swipeActions(edge: .leading) {
                            Button("Edit", systemImage: "pencil") { editing = occupation }
                                .tint(Theme.brown)
                        }
                        .swipeActions(edge: .trailing) {
                            MoveButtons(occupation: occupation, except: .now)
                        }
                    }
                    .onMove { planner.moveOccupations(in: domain, from: $0, to: $1) }
                    .onDelete { offsets in
                        for occupation in offsets.map({ occupations[$0] }) {
                            planner.move(occupation, to: .trash)
                        }
                    }
                } header: {
                    ScopeHeader(domain: domain)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .accessibilityIdentifier("occupations.list")
            .overlay {
                if occupations.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing yet", systemImage: "sparkles")
                    } description: {
                        Text("What would you do now for “\(domain.title)”?")
                    } actions: {
                        Button("Add an Occupation") { adding = true }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("scope.empty.add")
                    }
                    .padding(.top, 60)
                }
            }
        }
        .environment(\.editMode, $editMode)
        .toolbar {
            if !occupations.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editMode.isEditing ? "Done" : "Edit") {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { adding = true }
                    .accessibilityIdentifier("occupations.add")
            }
        }
        .sheet(isPresented: $adding) {
            EditorSheet(heading: "New Occupation", title: "", note: "") {
                planner.addOccupation(to: domain, title: $0, note: $1)
            }
        }
        .sheet(item: $editing) { occupation in
            EditorSheet(heading: "Occupation", title: occupation.title, note: occupation.note ?? "") {
                planner.update(occupation, title: $0, note: $1)
            }
        }
    }
}

/// The grey band with the scope's title above its list, as in 2011.
struct ScopeHeader: View {
    @ObservedObject var domain: Domain

    var body: some View {
        Text(domain.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .textCase(nil)
    }
}

/// One occupation in a list: the progress ring (or nothing), its title and the start of its note.
struct OccupationRow: View {
    @ObservedObject var occupation: Occupation
    let showsProgress: Bool

    var body: some View {
        HStack(spacing: 12) {
            if showsProgress {
                DotsRing(fraction: Double(occupation.progress) / 100, label: "\(occupation.progress)%")
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(occupation.title)
                    .foregroundStyle(Theme.ink)
                if let note = occupation.note, !note.isEmpty {
                    Text(note)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityValue(showsProgress ? "\(occupation.progress) percent" : "")
        .accessibilityIdentifier("occupation.\(occupation.title)")
    }
}

/// Swipe buttons that send an occupation to every other place.
struct MoveButtons: View {
    let occupation: Occupation
    let except: Status
    @Environment(Planner.self) private var planner

    var body: some View {
        ForEach([Status.trash, .completed, .someday, .now].filter { $0 != except }, id: \.self) { status in
            Button(status.title, systemImage: status.symbol) {
                withAnimation { planner.move(occupation, to: status) }
            }
            .tint(tint(status))
            .accessibilityIdentifier("move.\(status.title.lowercased())")
        }
    }

    private func tint(_ status: Status) -> Color {
        switch status {
        case .trash: .red
        case .completed: .green
        case .someday: .orange
        case .now: .blue
        }
    }
}
