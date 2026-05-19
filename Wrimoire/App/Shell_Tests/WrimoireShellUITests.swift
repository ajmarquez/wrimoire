import XCTest

final class WrimoireShellUITests: XCTestCase {
    func testLaunches() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
