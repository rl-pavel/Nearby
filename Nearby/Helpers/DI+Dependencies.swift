import Foundation
import ReSwift

extension Inject {
  static let Date = bind(Foundation.Date.self) { Foundation.Date() }
  static let UserDefaults = bind(Foundation.UserDefaults.self) { Foundation.UserDefaults.standard }
}
