import UIKit
import SnapKit

class EntryView: UIView {
  
  // MARK: - Properties
  
  let textView: UITextView = Init {
    $0.font = UIFont.preferredFont(forTextStyle: .body)
    $0.isScrollEnabled = false
  }
  let sendButton: UIButton = Init {
    $0.setImage(UIImage(symbol: "arrow.up.circle.fill", size: .smallButton), for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
  }
  
  private var _textViewHeightConstraint: Constraint?
  
  
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
  
  // MARK: - Functions
  
  func setUp() {
    addSubview(textView)
    textView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Int.x1_25)
      make.vertical.equalToSuperview().inset(1)
      _textViewHeightConstraint = make.height.equalTo(Int.textViewMinHeight).priority(.medium).constraint
      make.height.lessThanOrEqualTo(Int.textViewMaxHeight)
    }
    
    addSubview(sendButton)
    sendButton.snp.makeConstraints { make in
      make.size.equalTo(Int.smallButton)
      make.leading.equalTo(textView.snp.trailing).offset(Int.x1)
      make.trailing.equalToSuperview().inset(Int.x0_5)
      make.bottom.equalToSuperview().inset(Int.x0_5)
    }
    
    textView.delegate = self
    
    layer.cornerRadius = .x2_5
    layer.cornerCurve = .continuous
    layer.borderWidth = 1
    layer.borderColor = UIColor.systemFill.cgColor
  }
}


// MARK: - UITextViewDelegate Functions

extension EntryView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let exceedsHeightConstraint = textView.contentSize.height >= .textViewMaxHeight
    textView.isScrollEnabled = exceedsHeightConstraint
    _textViewHeightConstraint?.setActivated(!exceedsHeightConstraint)
  }
}
