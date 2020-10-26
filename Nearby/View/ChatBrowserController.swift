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
      make.top.horizontal.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalToSuperview()
    }
    tableView.delegate = self
    tableView.dataSource = self
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshDidChange), for: .valueChanged)
    view.backgroundColor = .systemBackground
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Inject.Store().subscribe(self) { subscription in
      subscription.skipRepeats { $0.guestChat ==? $1.guestChat }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Inject.Store().unsubscribe(self)
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
    Inject.Store().dispatch(BrowserState.Connection.reset)
  }
}


// MARK: - UITableView Functions

extension ChatBrowserController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : chats.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    
    if indexPath.section == 0 {
      let profile = Inject.Preferences().userProfile
      cell.textLabel?.text = "\(profile.name) (Your Chat)"
      
    } else {
      let profile = chats[indexPath.row].host
      cell.textLabel?.text = profile.name
      cell.imageView?.image = profile.avatar
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.section != 0 else {
      let chat = Inject.Store().state.hostChat
      show(ChatController(chat: chat), sender: self)
      return
    }
    
    let peerToJoin = chats[indexPath.row].host.peerId
    Inject.Store().dispatch(BrowserState.Invite.send(to: peerToJoin, Invitation(purpose: .joinRequest)))
  }
}
