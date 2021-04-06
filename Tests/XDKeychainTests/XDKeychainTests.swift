import XCTest
@testable import XDKeychain

final class XDKeychainTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XDKeychain().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
