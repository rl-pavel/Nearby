import UIKit

class RightMessageCell: UITableViewCell {
  
  // MARK: - Properties
  
  let containerView = Init(UIView()) {
    $0.roundCorners([.topLeft, .topRight, .bottomLeft], radius: 16)
    $0.backgroundColor = .systemBlue
  }
  
  let messageLabel = Init(UILabel()) {
    $0.apply(style: .body, color: .white)
    $0.textAlignment = .right
  }
  
  
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(2)
      make.trailing.equalToSuperview().inset(12)
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
    }
    
    containerView.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(8)
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


