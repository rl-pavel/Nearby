import UIKit
import SnapKit

class MessageEntryView: UIView {
  
  // MARK: - Properties
  
  let textView = Init(UITextView()) {
    $0.apply(style: .body, color: .label)
  }
  let sendButton = Init(UIButton()) {
    $0.setImage(UIImage(symbol: "arrow.up.circle.fill", size: .sendButton), for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
  }
  
  private var textViewHeightConstraint: Constraint?
  
  
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
      make.leading.equalToSuperview().inset(8)
      make.vertical.equalToSuperview()
      textViewHeightConstraint = make.height.equalTo(Int.messageEntryMinHeight).priority(.medium).constraint
      make.height.lessThanOrEqualTo(Int.messageEntryMaxHeight)
    }
    textView.delegate = self
    
    addSubview(sendButton)
    sendButton.snp.makeConstraints { make in
      make.size.equalTo(Int.sendButton)
      make.leading.equalTo(textView.snp.trailing)
      make.trailing.equalToSuperview().inset(2)
      make.bottom.equalToSuperview().inset(2)
    }
    
    backgroundColor = .systemBackground
    roundCorners(radius: 19, borderWidth: .pixel, borderColor: .systemGray3)
  }
}


// MARK: - UITextViewDelegate Functions

extension MessageEntryView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let exceedsHeightConstraint = textView.sizeThatFits(textView.contentSize).height >= .messageEntryMaxHeight
    textView.isScrollEnabled = exceedsHeightConstraint
    textViewHeightConstraint?.setActivated(!exceedsHeightConstraint)
  }
}
