@testable import Nearby
import ReSwift
import XCTest

extension XCTestCase {  
  func expect(_ description: String, times: Int = 1, assertOverFulfill: Bool = true) -> XCTestExpectation {
    let newExpectation = expectation(description: description)
    newExpectation.expectedFulfillmentCount = times
    newExpectation.assertForOverFulfill = assertOverFulfill
    return newExpectation
  }
  
  func waitFor(_ expectations: XCTestExpectation..., timeout: TimeInterval = 5) {
    wait(for: expectations, timeout: timeout)
  }
  
  /// Measures a block of code between calls to `startMeasuring()` and `stopMeasuring()`.
  func measureManually(_ measureBlock: VoidClosure) {
    measureMetrics([.wallClockTime], automaticallyStartMeasuring: false, for: measureBlock)
  }
}
