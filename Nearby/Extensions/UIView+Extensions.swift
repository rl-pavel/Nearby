import UIKit

extension UIView {
  var keyboardLayoutGuide: UILayoutGuide {
    if let existingGuide = layoutGuides.first(where: { $0 is KeyboardLayoutGuide }) {
      return existingGuide
    }
    
    let newGuide = KeyboardLayoutGuide()
    addLayoutGuide(newGuide)
    newGuide.setUp()
    
    return newGuide
  }
  
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
