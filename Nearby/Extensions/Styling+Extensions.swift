import UIKit

protocol TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor)
}

extension UITextView: TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor) {
    font = .preferredFont(forTextStyle: style)
    textColor = color
    textContainer.lineBreakMode = .byWordWrapping
    isScrollEnabled = false
    backgroundColor = .clear
  }
}


extension UILabel: TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor) {
    font = .preferredFont(forTextStyle: style)
    textColor = color
    numberOfLines = 0
    lineBreakMode = .byWordWrapping
  }
}


extension UIButton: TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor) {
    setTitleColor(color, for: .normal)
    titleLabel?.font = .preferredFont(forTextStyle: style)
    titleLabel?.numberOfLines = 0
    titleLabel?.lineBreakMode = .byWordWrapping
  }
}

extension CACornerMask {
  static var topLeft: CACornerMask { .layerMinXMinYCorner }
  static var topRight: CACornerMask { .layerMaxXMinYCorner }
  static var bottomLeft: CACornerMask { .layerMinXMaxYCorner }
  static var bottomRight: CACornerMask { .layerMaxXMaxYCorner }
  static var all: CACornerMask { [topLeft, topRight, bottomLeft, bottomRight] }
}

extension CALayer {
  func roundCorners(
    _ corners: CACornerMask,
    radius: CGFloat,
    borderWidth: CGFloat = 0,
    borderColor: UIColor = .clear) {
    cornerRadius = radius
    maskedCorners = corners
    cornerCurve = .continuous
    
    if borderWidth > 0 {
      self.borderWidth = borderWidth
      self.borderColor = borderColor.cgColor
    }
  }
}
