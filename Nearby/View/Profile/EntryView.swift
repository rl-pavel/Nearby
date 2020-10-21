import UIKit

class EntryView: UIView {
  
  // MARK: - Properties
  
  lazy var stackView = Init(UIStackView(arrangedSubviews: [titleLabel, textField])) {
    $0.axis = .vertical
    $0.spacing = 4
  }
  
  let titleLabel = Init(UILabel()) {
    $0.isUserInteractionEnabled = false
    $0.apply(style: .headline, color: .secondaryLabel)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }
  let textField = Init(UITextField()) {
    $0.apply(style: .body, color: .label)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }
  
  
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.vertical.equalToSuperview().inset(8)
      make.horizontal.equalToSuperview().inset(12)
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    addGestureRecognizer(tapRecognizer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
  
  @objc private func viewTapped() {
    textField.becomeFirstResponder()
  }
}
