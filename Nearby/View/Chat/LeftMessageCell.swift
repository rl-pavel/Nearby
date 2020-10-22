import UIKit

class LeftMessageCell: UITableViewCell {
  
  // MARK: - Properties
  
  static let avatarSize: CGFloat = 32
  
  let avatarView = Init(UIImageView()) {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(symbol: "person.crop.circle.fill", size: avatarSize)
    $0.roundCorners(radius: avatarSize / 2)
    $0.clipsToBounds = true
    $0.tintColor = .systemGray4
  }
  
  let messageBubbleView = Init(UIView()) {
    $0.roundCorners([.topLeft, .topRight, .bottomRight], radius: 16)
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
    
    contentView.addSubview(avatarView)
    avatarView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().inset(2)
      make.size.equalTo(Self.avatarSize)
    }
    
    contentView.addSubview(messageBubbleView)
    messageBubbleView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(2)
      make.leading.equalTo(avatarView.snp.trailing).offset(4)
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
    }
    
    messageBubbleView.addSubview(messageStack)
    messageStack.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(4)
      make.horizontal.equalToSuperview().inset(12)
    }
    
    // Flip the cell so it looks right side up in the table view.
    transform = CGAffineTransform(scaleX: 1, y: -1)
    selectionStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}
