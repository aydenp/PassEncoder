import XCTest
@testable import PassEncoder

final class PassEncoderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PassEncoder().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
