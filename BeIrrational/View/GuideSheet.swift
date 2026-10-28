import SwiftUI

/// How the app works, in a few steps: shown once on first launch and from the ? on the Now tab.
struct GuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct Step: Identifiable {
        let symbol: String
        let title: String
        let text: String
        var id: String { title }
    }

    private let steps = [
        Step(
            symbol: Status.now.symbol, title: "Scopes of your life",
            text: "On the Now tab, tap + to write a scope, such as “Take care of my health”, or pick one from the suggestions."),
        Step(
            symbol: "plus.circle", title: "Things to do now",
            text: "Tap a scope, then + to add the occupations you would do now. Tap one to set its progress; it counts the days since you began."),
        Step(
            symbol: Status.someday.symbol, title: "Someday",
            text: "Not now, but one day? On the Someday tab, tap + and write it down. Or swipe an occupation on the Now list to the left and choose Someday."),
        Step(
            symbol: "hand.draw", title: "Swipe to move",
            text: "Swipe any occupation to the left to send it to Now, Someday, Completed or Trash. Swipe it to the right to edit it."),
        Step(
            symbol: Status.completed.symbol, title: "Completed and Trash",
            text: "Done things land in Completed. Trashed ones wait in Trash until you tap Empty."),
    ]

    var body: some View {
        NavigationStack {
            List(steps) { step in
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text(step.text)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } icon: {
                    Image(systemName: step.symbol)
                        .font(.title2)
                        .foregroundStyle(Theme.brown)
                }
            }
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got It") { dismiss() }
                        .accessibilityIdentifier("guide.done")
                }
            }
        }
        .accessibilityIdentifier("guide")
    }
}
