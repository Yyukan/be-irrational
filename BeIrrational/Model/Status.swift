/// Where a scope or an occupation lives. The raw values are the ones the 2011 app wrote to the
/// store, so data from older versions keeps its place.
enum Status: Int16, CaseIterable, Sendable {
    case now = 0
    case trash = 1
    case someday = 2
    case completed = 3

    var title: String {
        switch self {
        case .now: "Now"
        case .someday: "Someday"
        case .completed: "Completed"
        case .trash: "Trash"
        }
    }

    var symbol: String {
        switch self {
        case .now: "lightbulb.max"
        case .someday: "tray"
        case .completed: "checkmark.square"
        case .trash: "trash"
        }
    }
}
