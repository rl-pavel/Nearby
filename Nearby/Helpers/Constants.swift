import UIKit

// MARK: - Layout Constants

protocol LayoutSpacing { }
extension Int: LayoutSpacing { }
extension CGFloat: LayoutSpacing {
  static let pixel: Self = 1 / UIScreen.main.scale
}

extension LayoutSpacing where Self: Numeric {
  static var sendButton: Self { 34 }
  static var messageEntryMinHeight: Self { 38 }
  static var messageEntryMaxHeight: Self { 148 }
  
}


// MARK: - Other Constants

enum Constants {
  static var invitationTimeout: TimeInterval { 10 }
}
