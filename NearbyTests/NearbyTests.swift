import XCTest

class NearbyTests: XCTestCase {
  func testTesting() {
    XCTAssertTrue(ProcessInfo.processInfo.arguments.contains("TESTING"))
  }
}
