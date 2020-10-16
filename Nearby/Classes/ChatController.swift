import UIKit
import MultipeerConnectivity
import ReSwift

class ChatController: UIViewController {
  
  // MARK: - Properties
  
  let isHost: Bool
  var messages = [Message]()
  let tableView = UITableView()
  
  let entryContainerView: UIView = Init { $0.backgroundColor = .quaternarySystemFill }
  let entryView = EntryView()
  
  
  // MARK: - Inits
  
  init(isHost: Bool) {
    self.isHost = isHost
    
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
    
    Store.subscribe(self) { $0.select(\.chatState) }
    
    let session = isHost ? ChatManager.shared.hostSession : ChatManager.shared.guestSession
    Store.dispatch(ChatState.SetSession(session: session))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if !isHost {
      ChatManager.shared.guestSession.disconnect()
    }
    Store.unsubscribe(self)
  }
  
  @objc func sendButtonTapped() {
    let myPeerId = ChatManager.shared.myPeerId
    
    guard let message = entryView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else {
      let session = Store.state.chatState.session
      navigationItem.title = "Connected: \(session?.connectedPeers.count ?? -1)"
      return
    }
    
    entryView.textView.text = nil
    Store.dispatch(ChatState.AddMessage(Message(sender: myPeerId.displayName, text: message)))
  }
}



// MARK: - Store Subscriber

extension ChatController: StoreSubscriber {
  func newState(state: ChatState) {
    messages = state.messages
    tableView.reloadData()
  }
}


// MARK: - UITableView Functions

extension ChatController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    
    let message = messages[indexPath.row]
    let myPeerId = ChatManager.shared.myPeerId
    let isMyMessage = message.sender == myPeerId.displayName
    
    cell.textLabel?.textAlignment = isMyMessage ? .right : .left
    cell.textLabel?.text = message.text
    
    return cell
  }
}
