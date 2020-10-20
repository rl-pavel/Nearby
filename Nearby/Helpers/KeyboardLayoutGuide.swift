import UIKit
import SnapKit

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
}


class KeyboardLayoutGuide: UILayoutGuide {
  
  // MARK: - Properties
  
  private static var keyboardHeight: CGFloat = 0
  
  
  // MARK: - Inits
  
  init(notificationCenter: NotificationCenter = NotificationCenter.default) {
    super.init()
    
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
  
  
  // MARK: - Functions
  
  func setUp() {
    guard let view = owningView else { return }
    
    snp.makeConstraints { make in
      make.horizontal.bottom.equalTo(view)
    }
  }
  
  @objc
  private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardHeight = notification.keyboardHeight,
          let duration = notification.animationDuration,
          let owningView = owningView else {
      return
    }
    
    snp.updateConstraints { make in
      make.bottom.equalTo(owningView).inset(keyboardHeight)
    }
    
    owningView.layoutIfNeeded(animatedWithDuration: TimeInterval(duration))
  }
}


// MARK: - Notification Helpers

fileprivate extension Notification {
  var keyboardHeight: CGFloat? {
    guard let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      return nil
    }
    
    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
    let screenHeight = window?.bounds.height ?? UIScreen.main.bounds.height
    
    return screenHeight - keyboardFrame.cgRectValue.minY
  }
  
  var animationDuration: CGFloat? {
    return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
  }
}
