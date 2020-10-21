import UIKit
import MultipeerConnectivity
import ReSwift

class ChatBrowserController: UIViewController {
  
  // MARK: - Properties
  
  let refreshControl = UIRefreshControl()
  let tableView = Init(UITableView(frame: .zero, style: .insetGrouped)) {
    $0.contentInset.top = 16
  }
  
  var chats = [ChatState]()
  
  
  // MARK: - Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Nearby Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(symbol: "person.crop.square", size: 20),
      style: .plain,
      target: self,
      action: #selector(profileButtonTapped))
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    tableView.delegate = self
    tableView.dataSource = self
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshDidChange), for: .valueChanged)
    view.backgroundColor = .systemBackground
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.subscribe(self) { subscription in
      subscription.skipRepeats {
        $0.guestChat != nil && $1.guestChat != nil && $0.guestChat == $1.guestChat
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Store.unsubscribe(self)
  }
}


// MARK: - Store Subscriber

extension ChatBrowserController: StoreSubscriber {
  func newState(state: AppState) {
    refreshControl.endRefreshing()
    
    chats = state.browser.chats
    tableView.reloadData()
    
    if let activeChat = state.guestChat {
      show(ChatController(chat: activeChat), sender: nil)
    }
  }
}


// MARK: - Helper Functions

private extension ChatBrowserController {
  @objc func profileButtonTapped() {
    let profileController = UINavigationController(rootViewController: ProfileController())
    present(profileController, animated: true, completion: nil)
  }
  
  @objc func refreshDidChange() {
    ChatManager.shared.stopDiscovery()
    Store.dispatch(BrowserState.Connection.reset)
    ChatManager.shared.startDiscovery()
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    let preferences = Preferences.shared
    preferences.userProfile.name = textField.text ?? UIDevice.current.name
    preferences.userProfile.peerId = .devicePeerId
    
    ChatManager.shared.setUpAndStartDiscovery()
  }
}


// MARK: - UITableView Functions

extension ChatBrowserController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chats.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    
    
    if indexPath.row == 0 {
      let profile = Preferences.shared.userProfile
      cell.textLabel?.text = "\(profile.name) (Your Chat)"
      
    } else {
      let profile = chats[indexPath.row - 1].host
      cell.textLabel?.text = profile.name
      cell.imageView?.image = profile.avatar
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.row != 0 else {
      let chat = Store.state.hostChat
      show(ChatController(chat: chat), sender: self)
      return
    }
    
    let peerToJoin = chats[indexPath.row - 1].host.peerId
    Store.dispatch(BrowserState.Invite.send(to: peerToJoin, Invitation(purpose: .joinRequest)))
  }
}
