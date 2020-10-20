import UIKit

class ProfileController: UIViewController {
  
  // MARK: - Properties
  
  let avatarImageView = Init(UIImageView()) {
    $0.roundCorners(.all, radius: 25)
    $0.image = UIImage(symbol: "person.crop.circle.fill.badge.plus", size: 100)
    $0.tintColor = .systemGray
    $0.contentMode = .center
    $0.backgroundColor = .systemGray6
  }
  
  lazy var userNameStack = Init(UIStackView(arrangedSubviews: [userNameLabel, userNameField])) {
    $0.axis = .vertical
    $0.spacing = 8
  }
  let userNameLabel = Init(UILabel()) {
    $0.apply(style: .headline, color: .label)
    $0.text = "Display Name:"
  }
  let userNameField = Init(UITextField()) {
    $0.apply(style: .body, color: .label)
    $0.borderStyle = .roundedRect
    $0.text = Preferences.shared.userProfile.name
  }
  
  
  // MARK: - Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Edit Profile"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(dismissTapped))
    
    view.addSubview(avatarImageView)
    avatarImageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.centerX.equalToSuperview()
      make.size.equalTo(150)
    }
    
    view.addSubview(userNameStack)
    userNameStack.snp.makeConstraints { make in
      make.top.equalTo(avatarImageView.snp.bottom).offset(40)
      make.horizontal.equalToSuperview().inset(16)
    }
    
    userNameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    view.backgroundColor = .secondarySystemBackground
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    ChatManager.shared.stopDiscovery()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    ChatManager.shared.setUpAndStartDiscovery()
  }
  
  
  // MARK: - Functions
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    let preferences = Preferences.shared
    
    preferences.userProfile.name = textField.text ?? UIDevice.current.name
    // Change the instance of the MCPeerId so that other devices will get the updated profile.
    preferences.userProfile.peerId = .devicePeerId
  }
  
  @objc func dismissTapped() {
    dismiss(animated: true, completion: nil)
  }
}
