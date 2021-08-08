import UIKit

// MARK: - Layout Constants

extension CGFloat {
  static let pixel: Self = 1 / UIScreen.main.scale
}


// MARK: - Other Constants

enum Constants {
  static var nearbyService: String = "nearby"
  static var userNameKey: String = "userName"
  static var invitationTimeout: TimeInterval = 10
}
