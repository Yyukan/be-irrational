import XCTest

/// The main flows on an empty in-memory store (debug builds only: `-uiTesting`).
@MainActor
final class FlowUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testFromEmptyToACompletedOccupation() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        // pick a suggested scope from the empty state
        app.buttons["empty.suggestions"].tap()
        app.buttons["suggestion.Take care of my health"].tap()
        app.buttons["suggestions.done"].tap()
        let scope = app.buttons["scope.Take care of my health"]
        XCTAssertTrue(scope.waitForExistence(timeout: 5))

        // add an occupation inside it
        scope.tap()
        app.buttons["scope.empty.add"].tap()
        let title = app.textFields["editor.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.typeText("Run a 10K")
        app.buttons["editor.save"].tap()
        let occupation = app.buttons["occupation.Run a 10K"]
        XCTAssertTrue(occupation.waitForExistence(timeout: 5))

        // swipe it to Completed
        occupation.swipeLeft()
        app.buttons["move.completed"].tap()
        XCTAssertFalse(occupation.waitForExistence(timeout: 2))

        app.tabBars.buttons["Completed"].tap()
        XCTAssertTrue(app.buttons["occupation.Run a 10K"].waitForExistence(timeout: 5))
    }

    func testTrashAndEmptyIt() {
        let app = XCUIApplication()
        app.launchArguments = ["-sampleData"]
        app.launch()

        app.buttons["scope.Take care of my health"].tap()
        let run = app.buttons["occupation.Run a 10K"]
        XCTAssertTrue(run.waitForExistence(timeout: 5))
        run.tap()
        XCTAssertEqual(app.staticTexts["card.title"].label, "Run a 10K")
        app.buttons["occupation.next"].tap()
        XCTAssertTrue(app.staticTexts["Sleep before midnight"].waitForExistence(timeout: 5))
        app.buttons["occupation.trash"].tap()
        XCTAssertTrue(app.staticTexts["Run a 10K"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Trash"].tap()
        XCTAssertTrue(app.buttons["occupation.Sleep before midnight"].waitForExistence(timeout: 5))
        app.buttons["trash.empty"].tap()
        app.buttons["Empty Trash"].firstMatch.tap()
        XCTAssertFalse(app.buttons["occupation.Sleep before midnight"].waitForExistence(timeout: 2))
    }
}
