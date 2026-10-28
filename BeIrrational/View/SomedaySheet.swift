import CoreData
import SwiftUI

/// A new occupation written straight onto the Someday list, in a scope picked from the Now tab.
struct SomedaySheet: View {
    @Environment(Planner.self) private var planner
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(fetchRequest: Domain.fetchNow()) private var scopes: FetchedResults<Domain>

    @State private var scope: Domain?
    @State private var title = ""
    @State private var note = ""
    @State private var newScope = ""
    @FocusState private var titleFocused: Bool

    private func trimmed(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Without any scope yet, the sheet asks for one by name and makes it.
    private var canSave: Bool {
        !trimmed(title).isEmpty && (scopes.isEmpty ? !trimmed(newScope).isEmpty : scope != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("What would you do one day?", text: $title)
                        .focused($titleFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier("editor.title")
                }
                Section {
                    if scopes.isEmpty {
                        TextField("A scope of your life, e.g. Travel", text: $newScope)
                            .accessibilityIdentifier("someday.newScope")
                    } else {
                        Picker("Scope", selection: $scope) {
                            ForEach(scopes) { domain in
                                Text(domain.title).tag(Optional(domain))
                            }
                        }
                        .accessibilityIdentifier("someday.scope")
                    }
                } header: {
                    Text("Scope")
                } footer: {
                    Text("When the time comes, swipe it on the Someday list to move it to Now.")
                }
                Section("Note") {
                    TextField("Details, ideas, anything", text: $note, axis: .vertical)
                        .lineLimit(3...10)
                        .accessibilityIdentifier("editor.note")
                }
            }
            .navigationTitle("New for Someday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                        .accessibilityIdentifier("editor.save")
                }
            }
            .onAppear {
                scope = scope ?? scopes.first
                titleFocused = true
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        guard canSave else { return }
        let domain = scope ?? planner.addScope(title: trimmed(newScope), note: "")
        planner.addOccupation(to: domain, title: trimmed(title), note: trimmed(note), status: .someday)
        dismiss()
    }
}
