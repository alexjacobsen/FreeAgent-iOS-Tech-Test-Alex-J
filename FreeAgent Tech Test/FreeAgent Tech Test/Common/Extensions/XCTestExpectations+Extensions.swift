import XCTest

extension XCTestCase {

    /// Convenience method to test a closure with expectation/timeout interval
    func wait(description: String = #function,
              timeout: TimeInterval = 30.0,
              testingClosure: (_ expectation: XCTestExpectation) -> Void) {

        let expectation = self.expectation(description: description)

        testingClosure(expectation)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
