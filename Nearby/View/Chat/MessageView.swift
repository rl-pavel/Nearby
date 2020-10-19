import UIKit

class MessageView: UIView {
  
  // MARK: - Properties
  
  lazy var messageStack = Init(UIStackView(arrangedSubviews: [senderLabel, messageLabel])) {
    $0.axis = .vertical
  }
  let senderLabel = Init(UILabel()) {
    $0.apply(style: .caption1, color: .secondaryLabel)
  }
  let messageLabel = Init(UILabel()) {
    $0.apply(style: .body, color: .label)
  }
  
  
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(messageStack)
    messageStack.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(Int.x1)
      make.horizontal.equalToSuperview().inset(Int.x1_5)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}
