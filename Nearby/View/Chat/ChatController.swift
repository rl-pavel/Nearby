import UIKit
import MultipeerConnectivity
import ReSwift

class ChatController: UIViewController {
  
  // MARK: - Properties
  
  var chat: ChatState
  let tableView = UITableView()
  
  let entryContainerView: UIView = Init { $0.backgroundColor = .quaternarySystemFill }
  let entryView = EntryView()
  
  
  // MARK: - Inits
  
  init(chat: ChatState) {
    self.chat = chat
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
  
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.horizontal.equalToSuperview()
    }
    tableView.delegate = self
    tableView.dataSource = self
    
    view.addSubview(entryContainerView)
    entryContainerView.snp.makeConstraints { make in
      make.top.equalTo(tableView.snp.bottom)
      make.horizontal.bottom.equalToSuperview()
    }
    
    entryContainerView.addSubview(entryView)
    entryView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Int.x1)
      make.horizontal.equalToSuperview().inset(Int.x1_5)
      make.bottom.equalTo(view.keyboardLayoutGuide).inset(Int.x1).priority(.high)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
    }
    
    entryView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Store.dispatch(ChatState.SetGuestChat(chat: nil))
    Store.unsubscribe(self)
  }
  
  @objc func sendButtonTapped() {
    guard let message = entryView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else {
//      let session = Store.state.chatState.session
//      navigationItem.title = "Connected: \(session?.connectedPeers.count ?? -1)"
      return
    }
    
    entryView.textView.text = nil
    Store.dispatch(ChatState.SendMessage(Message(text: message), in: chat))
  }
}


// MARK: - Store Subscriber

extension ChatController: StoreSubscriber {
  func newState(state: AppState) {
    // TODO: - Implement host disconnection.
    chat = state.guestChat ?? state.hostChat
    tableView.reloadData()
  }
}


// MARK: - UITableView Functions

extension ChatController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chat.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    
    let message = chat.messages[indexPath.row]
    let myPeerId = ChatManager.shared.userPeer
    let isMyMessage = message.sender == myPeerId.displayName
    
    cell.textLabel?.textAlignment = isMyMessage ? .right : .left
    cell.textLabel?.text = message.text
    
    return cell
  }
}
