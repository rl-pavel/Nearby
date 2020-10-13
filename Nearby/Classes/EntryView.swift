import UIKit
import SnapKit

class EntryView: UIView {
  
  // MARK: - Properties
  
  let textView: UITextView = Init {
    $0.font = UIFont.preferredFont(forTextStyle: .body)
    $0.backgroundColor = .clear
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
      make.leading.equalToSuperview().inset(Int.x1)
      make.top.equalToSuperview().inset(- 2)
      make.bottom.equalToSuperview().inset(-3)
      _textViewHeightConstraint = make.height.equalTo(Int.textViewMinHeight).priority(.medium).constraint
      make.height.lessThanOrEqualTo(Int.textViewMaxHeight)
    }
    
    addSubview(sendButton)
    sendButton.snp.makeConstraints { make in
      make.size.equalTo(Int.smallButton)
      make.leading.equalTo(textView.snp.trailing).offset(Int.x1)
      make.trailing.equalToSuperview().inset(Int.x0_25)
      make.bottom.equalToSuperview().inset(Int.x0_25)
    }
    
    textView.delegate = self
    
    backgroundColor = .systemBackground
    
    layer.cornerRadius = 16
    layer.cornerCurve = .continuous
    layer.borderWidth = 1
    layer.borderColor = UIColor.systemGray3.cgColor
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
