import SwiftUI

/// Four tabs, as in 2011: Now, Someday, Completed, Trash.
struct RootView: View {
    @State private var tab = Launch.tab
    @State private var nowPath = NavigationPath()
    @Environment(Planner.self) private var planner

    var body: some View {
        TabView(selection: $tab) {
            Tab(Status.now.title, systemImage: Status.now.symbol, value: Status.now) {
                NavigationStack(path: $nowPath) {
                    ScopesView().withDestinations()
                }
            }
            ForEach([Status.someday, .completed, .trash], id: \.self) { status in
                Tab(status.title, systemImage: status.symbol, value: status) {
                    NavigationStack {
                        ShelfView(status: status).withDestinations()
                    }
                }
            }
        }
        .tint(Theme.brown)
        .onAppear { nowPath = Launch.path(planner) }
    }
}

extension View {
    func withDestinations() -> some View {
        navigationDestination(for: OccupationPage.self) { OccupationView(page: $0) }
    }
}
