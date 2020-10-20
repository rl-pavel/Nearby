import UIKit

protocol TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor)
}


extension UITextField: TextStyling {
  func apply(style: UIFont.TextStyle, color: UIColor) {
    font = .preferredFont(forTextStyle: style)
    textColor = color
  }
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
