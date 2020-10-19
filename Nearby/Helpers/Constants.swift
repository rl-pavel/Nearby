import UIKit

// MARK: - Layout Constants

protocol LayoutSpacing { }
extension Int: LayoutSpacing { }
extension CGFloat: LayoutSpacing { }

extension LayoutSpacing where Self: Numeric {
  static var x0_25: Self { 2 }
  static var x0_5: Self { 4 }
  static var x0_75: Self { 6 }
  static var x1: Self { 8 }
  static var x1_25: Self { 10 }
  static var x1_5: Self { 12 }
  static var x2: Self { 16 }
  static var x2_5: Self { 20 }
  static var x3: Self { 24 }
  static var x4: Self { 32 }
  static var x5: Self { 40 }
  
  static var smallButton: Self { 28 }
  static var textViewMinHeight: Self { 35 }
  static var textViewMaxHeight: Self { 148 }
  
}


// MARK: - Other Constants

enum Constants {
  static var invitationTimeout: TimeInterval { 10 }
}
