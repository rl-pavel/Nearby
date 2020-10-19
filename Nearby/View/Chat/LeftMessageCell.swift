import UIKit

class LeftMessageCell: UITableViewCell {
  
  // MARK: - Properties
  
  let messageView = Init(MessageView()) {
    $0.layer.roundCorners([.topLeft, .topRight, .bottomRight], radius: 16)
    $0.backgroundColor = .systemFill
  }
  
  
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(messageView)
    messageView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(Int.x0_25)
      make.leading.equalToSuperview().inset(Int.x1_5)
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
    }
    
    // Flip the cell so it looks right side up in the table view.
    transform = CGAffineTransform(scaleX: 1, y: -1)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}

class RightMessageCell: UITableViewCell {
  
  // MARK: - Properties
  
  let messageView = Init(MessageView()) {
    $0.senderLabel.isHidden = true
    $0.messageLabel.textColor = .white
    $0.messageLabel.textAlignment = .right
    $0.backgroundColor = .systemBlue
    $0.layer.roundCorners([.topLeft, .topRight, .bottomLeft], radius: 16)
  }
  
  
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(messageView)
    messageView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(Int.x0_25)
      make.trailing.equalToSuperview().inset(Int.x1_5)
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
    }
    
    // Flip the cell so it looks right side up in the table view.
    transform = CGAffineTransform(scaleX: 1, y: -1)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}

