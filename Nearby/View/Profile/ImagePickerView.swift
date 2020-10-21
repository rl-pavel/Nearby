import UIKit

class ImagePickerView: UIView {
  
  // MARK: - Properties
  
  let imageButton = Init(UIButton()) {
    $0.tintColor = .systemGray
    $0.imageView?.contentMode = .scaleAspectFit
    $0.roundCorners(radius: 26)
    $0.clipsToBounds = true
  }
  
  var image: UIImage? {
    get { return imageButton.imageView?.image }
    set { imageButton.setImage(newValue, for: .normal) }
  }
  
  
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    
    addSubview(imageButton)
    imageButton.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(4)
      make.width.equalTo(imageButton.snp.height)
    }
    
    roundCorners(radius: 30)
    backgroundColor = .secondarySystemBackground
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
}
