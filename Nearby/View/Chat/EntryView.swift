import UIKit
import SnapKit

class EntryView: UIView {
  
  // MARK: - Properties
  
  let textView = Init(UITextView()) {
    $0.apply(style: .body, color: .label)
  }
  let sendButton = Init(UIButton()) {
    $0.setImage(UIImage(symbol: "arrow.up.circle.fill", size: .smallButton), for: .normal)
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
      make.leading.equalToSuperview().inset(Int.x1)
      make.vertical.equalToSuperview()
      textViewHeightConstraint = make.height.equalTo(Int.textViewMinHeight).priority(.medium).constraint
      make.height.lessThanOrEqualTo(Int.textViewMaxHeight)
    }
    textView.delegate = self
    
    addSubview(sendButton)
    sendButton.snp.makeConstraints { make in
      make.size.equalTo(Int.smallButton)
      make.leading.equalTo(textView.snp.trailing)
      make.trailing.equalToSuperview().inset(Int.x0_25)
      make.bottom.equalToSuperview().inset(Int.x0_25)
    }
    
    backgroundColor = .systemBackground
    layer.roundCorners(.all, radius: 19, borderWidth: .pixel, borderColor: .systemGray3)
  }
}


// MARK: - UITextViewDelegate Functions

extension EntryView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let exceedsHeightConstraint = textView.sizeThatFits(textView.contentSize).height >= .textViewMaxHeight
    textView.isScrollEnabled = exceedsHeightConstraint
    textViewHeightConstraint?.setActivated(!exceedsHeightConstraint)
  }
}
