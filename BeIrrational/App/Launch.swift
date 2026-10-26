import SwiftUI

/// How the app starts. Release builds always open the real store on the Now tab; debug builds
/// also take launch arguments for tests and App Store screenshots:
///
/// - `-uiTesting`: an empty in-memory store
/// - `-sampleData`: an in-memory store filled with sample scopes and occupations
/// - `-tab someday|completed|trash`: the tab to open
/// - `-open scope|occupation`: push the first scope, or its first occupation, on the Now tab
@MainActor
enum Launch {
    static func makePlanner() -> Planner {
        #if DEBUG
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-sampleData") {
                let planner = Planner(inMemory: true)
                SampleData.fill(planner)
                return planner
            }
            if arguments.contains("-uiTesting") {
                return Planner(inMemory: true)
            }
        #endif
        return Planner()
    }

    static var tab: Status {
        #if DEBUG
            switch UserDefaults.standard.string(forKey: "tab") {
            case "someday": return .someday
            case "completed": return .completed
            case "trash": return .trash
            default: return .now
            }
        #else
            return .now
        #endif
    }

    static func path(_ planner: Planner) -> NavigationPath {
        var path = NavigationPath()
        #if DEBUG
            guard let open = UserDefaults.standard.string(forKey: "open"),
                let domain = planner.scopes().first
            else { return path }
            path.append(domain)
            if open == "occupation" {
                let ids = planner.occupations(in: domain, status: .now).map(\.objectID)
                if !ids.isEmpty { path.append(OccupationPage(ids, at: 0, from: .now)) }
            }
        #endif
        return path
    }
}
