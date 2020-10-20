import UIKit

extension UIView {
  func layoutIfNeeded(
    animatedWithDuration duration: TimeInterval,
    animations: (() -> Void)? = nil,
    completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: duration, animations: {
      animations?()
      self.layoutIfNeeded()
    }) { _ in
      completion?()
    }
  }
}
