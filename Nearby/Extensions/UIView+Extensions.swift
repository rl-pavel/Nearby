import UIKit

extension UIView {
  func layoutIfNeeded(
    animatedWithDuration duration: TimeInterval,
    animations: VoidClosure? = nil,
    completion: VoidClosure? = nil) {
    UIView.animate(withDuration: duration, animations: {
      animations?()
      self.layoutIfNeeded()
    }) { _ in
      completion?()
    }
  }
  
  func roundCorners(
    _ corners: CACornerMask = .all,
    radius: CGFloat,
    borderWidth: CGFloat = 0,
    borderColor: UIColor = .clear) {
    layer.cornerRadius = radius
    layer.maskedCorners = corners
    layer.cornerCurve = .continuous
    
    if borderWidth > 0 {
      self.layer.borderWidth = borderWidth
      self.layer.borderColor = borderColor.cgColor
    }
  }
}


extension CACornerMask {
  static var topLeft: CACornerMask { .layerMinXMinYCorner }
  static var topRight: CACornerMask { .layerMaxXMinYCorner }
  static var bottomLeft: CACornerMask { .layerMinXMaxYCorner }
  static var bottomRight: CACornerMask { .layerMaxXMaxYCorner }
  static var all: CACornerMask { [topLeft, topRight, bottomLeft, bottomRight] }
}
