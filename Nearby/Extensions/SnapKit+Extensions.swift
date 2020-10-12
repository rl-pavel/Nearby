import UIKit
import SnapKit

extension ConstraintMaker {
  var horizontal: ConstraintMakerExtendable {
    return leading.trailing
  }
  
  var vertical: ConstraintMakerExtendable {
    return top.bottom
  }
}

extension ConstraintMakerExtendable {
  var horizontal: ConstraintMakerExtendable {
    return leading.trailing
  }
  
  var vertical: ConstraintMakerExtendable {
    return top.bottom
  }
}

extension Constraint {
  func setActivated(_ isActivated: Bool) {
    if isActivated {
      activate()
    } else {
      deactivate()
    }
  }
}
