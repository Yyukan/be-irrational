import CoreData
import XCTest

@testable import BeIrrational

@MainActor
final class PlannerTests: XCTestCase {
    private var planner: Planner!

    override func setUp() async throws {
        planner = Planner(inMemory: true)
    }

    // MARK: - Scopes

    func testScopesKeepTheOrderTheyWereAddedIn() {
        planner.addScope(title: "A", note: "")
        planner.addScope(title: "B", note: "")
        planner.addScope(title: "C", note: "")
        XCTAssertEqual(planner.scopes().map(\.title), ["A", "B", "C"])
        XCTAssertEqual(planner.scopes().map(\.order), [0, 1, 2])
    }

    func testMovingAScopeRenumbersTheList() {
        for title in ["A", "B", "C"] { planner.addScope(title: title, note: "") }
        planner.moveScopes(from: [2], to: 0)
        XCTAssertEqual(planner.scopes().map(\.title), ["C", "A", "B"])
        XCTAssertEqual(planner.scopes().map(\.order), [0, 1, 2])
    }

    func testDeletingAScopeDeletesItsOccupationsEverywhere() {
        let a = planner.addScope(title: "A", note: "")
        let b = planner.addScope(title: "B", note: "")
        planner.addOccupation(to: a, title: "now", note: "")
        planner.move(planner.addOccupation(to: a, title: "later", note: ""), to: .someday)
        planner.addOccupation(to: b, title: "kept", note: "")

        planner.delete(a)

        XCTAssertEqual(planner.scopes().map(\.title), ["B"])
        XCTAssertEqual(b.order, 0)
        let all = try? planner.context.fetch(NSFetchRequest<Occupation>(entityName: "Occupation"))
        XCTAssertEqual(all?.map(\.title), ["kept"])
    }

    func testSuggestionsAreRecognisedOnceAdded() {
        let suggestion = SuggestedScope.all[0]
        XCTAssertFalse(planner.has(suggestion))
        planner.addScope(title: suggestion.title, note: suggestion.note)
        XCTAssertTrue(planner.has(suggestion))
    }

    // MARK: - Occupations

    func testMovingAnOccupationAppendsItAndClosesTheGap() {
        let scope = planner.addScope(title: "S", note: "")
        let first = planner.addOccupation(to: scope, title: "1", note: "")
        planner.addOccupation(to: scope, title: "2", note: "")
        planner.addOccupation(to: scope, title: "3", note: "")
        let parked = planner.addOccupation(to: scope, title: "parked", note: "")
        planner.move(parked, to: .someday)

        planner.move(first, to: .someday)

        XCTAssertEqual(planner.occupations(in: scope, status: .now).map(\.title), ["2", "3"])
        XCTAssertEqual(planner.occupations(in: scope, status: .now).map(\.order), [0, 1])
        XCTAssertEqual(planner.occupations(in: scope, status: .someday).map(\.title), ["parked", "1"])
        XCTAssertEqual(first.place, .someday)
    }

    func testMoveAllTakesOnlyTheNowList() {
        let scope = planner.addScope(title: "S", note: "")
        planner.addOccupation(to: scope, title: "1", note: "")
        planner.addOccupation(to: scope, title: "2", note: "")
        planner.move(planner.addOccupation(to: scope, title: "done", note: ""), to: .completed)

        planner.moveAll(in: scope, to: .trash)

        XCTAssertTrue(planner.occupations(in: scope, status: .now).isEmpty)
        XCTAssertEqual(planner.occupations(in: scope, status: .trash).map(\.title), ["1", "2"])
        XCTAssertEqual(planner.occupations(in: scope, status: .completed).map(\.title), ["done"])
        XCTAssertEqual(scope.activeCount, 0)
    }

    func testAnOccupationCanBeWrittenStraightIntoSomeday() {
        let domain = planner.addScope(title: "Travel", note: "")
        planner.addOccupation(to: domain, title: "Now", note: "")
        planner.addOccupation(to: domain, title: "Japan", note: "", status: .someday)
        planner.addOccupation(to: domain, title: "Iceland", note: "", status: .someday)
        XCTAssertEqual(planner.occupations(in: domain, status: .now).map(\.title), ["Now"])
        XCTAssertEqual(planner.occupations(in: domain, status: .someday).map(\.title), ["Japan", "Iceland"])
        XCTAssertEqual(planner.occupations(in: domain, status: .someday).map(\.order), [0, 1])
    }

    func testReorderingOccupations() {
        let scope = planner.addScope(title: "S", note: "")
        for title in ["1", "2", "3"] { planner.addOccupation(to: scope, title: title, note: "") }
        planner.moveOccupations(in: scope, from: [0], to: 3)
        XCTAssertEqual(planner.occupations(in: scope, status: .now).map(\.title), ["2", "3", "1"])
    }

    func testFullProgressStampsTheDayItWasDone() {
        let scope = planner.addScope(title: "S", note: "")
        let occupation = planner.addOccupation(to: scope, title: "1", note: "")
        planner.setProgress(occupation, to: 60)
        XCTAssertEqual(occupation.progress, 60)
        XCTAssertNil(occupation.completedDate)

        planner.setProgress(occupation, to: 100)
        XCTAssertNotNil(occupation.completedDate)

        planner.setProgress(occupation, to: 140)
        XCTAssertEqual(occupation.progress, 100)

        planner.setProgress(occupation, to: 95)
        XCTAssertNil(occupation.completedDate)
    }

    func testDaysCountFromTheStartToTodayOrToCompletion() {
        let scope = planner.addScope(title: "S", note: "")
        let occupation = planner.addOccupation(to: scope, title: "1", note: "")
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 23))!
        occupation.date = start
        let now = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11, hour: 1))!
        XCTAssertEqual(occupation.days(now: now, calendar: calendar), 10)

        occupation.completedDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 4))!
        XCTAssertEqual(occupation.days(now: now, calendar: calendar), 3)
    }

    func testEmptyTrashDeletesOnlyTheTrash() {
        let scope = planner.addScope(title: "S", note: "")
        planner.addOccupation(to: scope, title: "kept", note: "")
        planner.move(planner.addOccupation(to: scope, title: "gone", note: ""), to: .trash)
        planner.emptyTrash()
        let all = try? planner.context.fetch(NSFetchRequest<Occupation>(entityName: "Occupation"))
        XCTAssertEqual(all?.map(\.title), ["kept"])
    }

    // MARK: - Data from 1.2

    /// A store written by the 2011 Objective-C app (built from the original sources) opens as is.
    func testOpensTheStoreOfVersion12() throws {
        let fixture = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "Legacy-1.2", withExtension: "sqlite", subdirectory: "Fixtures"))
        let copy = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        try FileManager.default.copyItem(at: fixture, to: copy)

        let legacy = Planner(storeURL: copy)

        XCTAssertEqual(legacy.scopes().map(\.title), ["Improve family relationship", "Legacy scope from 2013"])
        let family = legacy.scopes()[0]
        XCTAssertEqual(
            legacy.occupations(in: family, status: .now).map(\.title),
            ["Make calendar with important family dates", "Arrange family picnic"])
        XCTAssertEqual(legacy.occupations(in: family, status: .now).map(\.progress), [20, 90])
        XCTAssertEqual(legacy.occupations(in: family, status: .someday).map(\.title), ["Visit grandparents"])
        let old = legacy.scopes()[1]
        XCTAssertEqual(legacy.occupations(in: old, status: .completed).map(\.title), ["Finished thing"])
        XCTAssertEqual(legacy.occupations(in: old, status: .trash).map(\.title), ["Trashed thing"])

        // and it can write to it
        legacy.addOccupation(to: old, title: "New in 1.3", note: "")
        let reopened = Planner(storeURL: copy)
        XCTAssertEqual(reopened.occupations(in: reopened.scopes()[1], status: .now).map(\.title), ["New in 1.3"])
    }
}
