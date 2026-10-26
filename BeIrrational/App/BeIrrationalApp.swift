import SwiftUI

@main
struct BeIrrationalApp: App {
    @State private var planner = Launch.makePlanner()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(planner)
                .environment(\.managedObjectContext, planner.context)
        }
    }
}
