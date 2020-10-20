import UIKit

class LeftMessageCell: UITableViewCell {
  
  // MARK: - Properties
  
  let containerView = Init(UIView()) {
    $0.layer.roundCorners([.topLeft, .topRight, .bottomRight], radius: 16)
    $0.backgroundColor = .systemFill
  }
  
  lazy var messageStack = Init(UIStackView(arrangedSubviews: [senderLabel, messageLabel])) {
    $0.axis = .vertical
  }
  let senderLabel = Init(UILabel()) {
    $0.apply(style: .caption2, color: .secondaryLabel)
  }
  let messageLabel = Init(UILabel()) {
    $0.apply(style: .body, color: .label)
  }
  
  
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(Int.x0_25)
      make.leading.equalToSuperview().inset(Int.x1_5)
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
    }
    
    containerView.addSubview(messageStack)
    messageStack.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(Int.x0_5)
      make.horizontal.equalToSuperview().inset(Int.x1_5)
    }
    
    // Flip the cell so it looks right side up in the table view.
    transform = CGAffineTransform(scaleX: 1, y: -1)
    selectionStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}
