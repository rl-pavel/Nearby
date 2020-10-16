import UIKit
import SnapKit
import MultipeerConnectivity
import ReSwift

class ChatBrowserController: UIViewController {
  
  // MARK: - Properties
  
  let nameField: UITextField = Init {
    $0.text = Preferences.shared.userName
    $0.backgroundColor = .quaternarySystemFill
  }
  let searchButton: UIButton = Init {
    $0.setTitle("Advertise", for: .normal)
    $0.setTitleColor(.systemBlue, for: .normal)
  }
  
  let tableView = UITableView()
  var peers = [MCPeerID]()
  
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Nearby Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    view.addSubview(nameField)
    nameField.snp.makeConstraints { make in
      make.top.horizontal.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(Int.textViewMinHeight)
    }
    nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    view.addSubview(searchButton)
    searchButton.snp.makeConstraints { make in
      make.vertical.trailing.equalTo(nameField)
    }
    searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(nameField.snp.bottom)
      make.horizontal.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.subscribe(self)
    search()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Store.unsubscribe(self)
    ChatManager.shared.browser.stopBrowsingForPeers()
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    textField.text?.nonEmpty.map {
      Preferences.shared.userName = $0
      ChatManager.shared.myPeerId = MCPeerID(displayName: $0)
    }
  }
  
  @objc func search() {
    ChatManager.shared.startDiscovery()
    Store.dispatch(BrowserState.SetState(state: .browsing))
  }
}


// MARK: - Store Subscriber

extension ChatBrowserController: StoreSubscriber {
  func newState(state: State) {
    peers = state.browserState.peers
    tableView.reloadData()
    
    if state.browserState.state == .invited {
      show(ChatController(isHost: false), sender: self)
    }
  }
}


// MARK: - UITableView Functions

extension ChatBrowserController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peers.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    
    if indexPath.row == 0 {
      cell.textLabel?.text = "Your Chat"
    } else {
      cell.textLabel?.text = peers[indexPath.row - 1].displayName
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.row != 0 else {
      show(ChatController(isHost: true), sender: self)
      return
    }
    
    let peerToJoin = peers[indexPath.row - 1]
    Store.dispatch(BrowserState.Peer.join(peerToJoin))
  }
}
