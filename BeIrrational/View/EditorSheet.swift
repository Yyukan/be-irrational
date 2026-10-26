import SwiftUI

/// Title and note of a scope or an occupation, new or existing.
struct EditorSheet: View {
    let heading: String
    @State var title: String
    @State var note: String
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("What is it?", text: $title)
                        .focused($titleFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier("editor.title")
                }
                Section("Note") {
                    TextField("Details, ideas, anything", text: $note, axis: .vertical)
                        .lineLimit(3...10)
                        .accessibilityIdentifier("editor.note")
                }
            }
            .navigationTitle(heading)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                    .disabled(trimmedTitle.isEmpty)
                    .accessibilityIdentifier("editor.save")
                }
            }
            .onAppear { titleFocused = title.isEmpty }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        guard !trimmedTitle.isEmpty else { return }
        onSave(trimmedTitle, note.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}
