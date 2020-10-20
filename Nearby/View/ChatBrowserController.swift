import UIKit
import MultipeerConnectivity
import ReSwift

class ChatBrowserController: UIViewController {
  
  // MARK: - Properties
  
  // TODO: - Create a dedicated ProfileController.
  let nameField = Init(UITextField()) {
    $0.text = Preferences.shared.userProfile.name
    $0.backgroundColor = .quaternarySystemFill
  }
  
  let refreshControl = UIRefreshControl()
  let tableView = UITableView()
  
  var chats = [ChatState]()
  
  
  // MARK: - Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Nearby Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    view.addSubview(nameField)
    nameField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.horizontal.equalToSuperview()
      make.height.equalTo(Int.textViewMinHeight)
    }
    nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(nameField.snp.bottom)
      make.horizontal.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    tableView.delegate = self
    tableView.dataSource = self
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.subscribe(self) { subscription in
      subscription.skipRepeats { $0.guestChat != nil && $1.guestChat != nil && $0.guestChat == $1.guestChat }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Store.unsubscribe(self)
  }
  
  
  // MARK: - Functions
  
  @objc func pullToRefresh() {
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
