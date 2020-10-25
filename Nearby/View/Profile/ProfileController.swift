import UIKit

class ProfileController: UIViewController {
  
  // MARK: - Properties
  
  static let imageFrameSize: CGFloat = 140
  static let imageSize: CGFloat = 256
  
  let avatarPickerView = Init(ImagePickerView()) {
    let image = Inject.Preferences().userProfile.avatar
      ?? UIImage(symbol: "person.crop.circle.fill.badge.plus", size: imageSize)
    $0.imageButton.setImage(image, for: .normal)
  }
  
  let entryView = Init(EntryView()) {
    $0.titleLabel.text = "Display Name:"
    $0.textField.text = Inject.Preferences().userProfile.name
    $0.backgroundColor = .secondarySystemBackground
    $0.roundCorners(radius: 12)
  }
  
  private var didChangeAvatar = false
  private lazy var imagePickerController = Init(UIImagePickerController()) {
    $0.delegate = self
    $0.allowsEditing = true
    $0.mediaTypes = ["public.image"]
    $0.sourceType = .savedPhotosAlbum
  }
  
  
  // MARK: - Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Edit Profile"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelTapped))
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(saveTapped))
    
    view.addSubview(avatarPickerView)
    avatarPickerView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.centerX.equalToSuperview()
      make.size.equalTo(Self.imageFrameSize).priority(.high)
      make.size.lessThanOrEqualTo(Self.imageFrameSize)
    }
    avatarPickerView.imageButton.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)

    view.addSubview(entryView)
    entryView.snp.makeConstraints { make in
      make.top.equalTo(avatarPickerView.snp.bottom).offset(24)
      make.horizontal.width.equalToSuperview().inset(16)
      make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide).inset(8)
    }
    
    view.backgroundColor = .systemBackground
  }
}


// MARK: - Helper Functions

private extension ProfileController {
  @objc func pickImageTapped() {
    present(imagePickerController, animated: true)
  }
  
  @objc func saveTapped() {
    guard let displayName = entryView.textField.text?.trimmingCharacters(in: .whitespaces).nonEmpty else {
      // TODO: - Provide feedback to user - can't set an empty username.
      return
    }
    
    let newAvatar = didChangeAvatar ? avatarPickerView.image : nil
    Inject.Store().dispatch(AppState.UpdateProfile(avatar: newAvatar, name: displayName))

    dismiss(animated: true, completion: nil)
  }
  
  @objc func cancelTapped() {
    dismiss(animated: true, completion: nil)
  }
}


// MARK: - UIImagePickerControllerDelegate Functions

extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    defer { picker.dismiss(animated: true, completion: nil) }
    
    guard let image = info[.editedImage] as? UIImage,
          let croppedImage = image.resized(toWidth: Self.imageSize) else {
      return
    }
    
    avatarPickerView.image = croppedImage
    didChangeAvatar = true
  }
}
