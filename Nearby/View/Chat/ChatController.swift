import UIKit
import ReSwift

class ChatController: UIViewController {
  
  // MARK: - Properties
  
  var chat: ChatState
  let tableView = Init(UITableView()) {
    $0.contentInset = .init(top: 4, left: 0, bottom: 0, right: 0)
    $0.separatorStyle = .none
    // Flip the table-view upside down so the messages are added bottom-up.
    $0.transform = CGAffineTransform(scaleX: 1, y: -1)
  }
  
  let entryContainerView = Init(UIView()) {
    $0.backgroundColor = .quaternarySystemFill
  }
  let messageEntryView = MessageEntryView()
  
  
  // MARK: - Inits
  
  init(chat: ChatState) {
    self.chat = chat
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not Implemented")
  }
  
  
  // MARK: - Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "\(chat.host.name) Chat"
    navigationItem.largeTitleDisplayMode = .never
    
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
    
    entryContainerView.addSubview(messageEntryView)
    messageEntryView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(8)
      make.horizontal.equalToSuperview().inset(12)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.keyboardLayoutGuide).inset(8).priority(.high)
    }
    messageEntryView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    
    view.backgroundColor = .systemBackground
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Inject.Store().subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    Inject.Store().dispatch(AppState.SetGuestChat(chat: nil))
    Inject.Store().unsubscribe(self)
  }
}


// MARK: - Store Subscriber

extension ChatController: StoreSubscriber {
  func newState(state: AppState) {
    let newChat = state.guestChat ?? state.hostChat
    
    // If the new (guest) chat's host is different to the current one - it got disconnected.
    guard newChat.host == chat.host else {
      handleDisconnection()
      return
    }
    
    chat = newChat
    tableView.reloadData()
  }
}


// MARK: - Helper Functions

private extension ChatController {
  @objc func sendButtonTapped() {
    guard let message = messageEntryView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else {
      return
    }
    
    messageEntryView.textView.text.removeAll()
    messageEntryView.textViewDidChange(messageEntryView.textView)
    Inject.Store().dispatch(ChatState.SendMessage(Message(text: message), in: chat))
  }
  
  func handleDisconnection() {
    let disconnectionAlert = UIAlertController(
      title: "\(chat.host.name) Disconnected",
      message: "If the host becomes available again, you will be able to reconnect.",
      preferredStyle: .alert)
    let closeAction = UIAlertAction(title: "Close", style: .cancel) { _ in
      self.navigationController?.popViewController(animated: true)
    }
    
    disconnectionAlert.addAction(closeAction)
    present(disconnectionAlert, animated: true, completion: nil)
  }
}


// MARK: - UITableView Functions

extension ChatController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chat.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = chat.messages[indexPath.row]
    let currentUserProfile = Inject.Preferences().userProfile
    
    // TODO: - Implement MessageViewModel
    if message.sender == currentUserProfile {
      let cell = tableView.dequeueReusableCell(RightMessageCell.self)
      cell.messageLabel.text = message.text
      return cell
      
    } else {
      let cell = tableView.dequeueReusableCell(LeftMessageCell.self)
      message.sender.avatar.map { cell.avatarView.image = $0 }
      cell.senderLabel.text = message.sender.name
      cell.messageLabel.text = message.text
      return cell
    }
  }
}
