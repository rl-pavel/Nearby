import UIKit
import MultipeerConnectivity

class ChatController: UIViewController {
  
  // MARK: - Properties
  
  var messages = [String]()
  let tableView = UITableView()
  
  let entryContainerView: UIView = Init { $0.backgroundColor = .quaternarySystemFill }
  let entryView = EntryView()
  
  let peerID = MCPeerID(displayName: "Pavel")
  lazy var session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
  lazy var browser = MCNearbyServiceBrowser(
    peer: peerID,
    serviceType: "nearby")
  lazy var advertiser = MCNearbyServiceAdvertiser(
    peer: peerID,
    discoveryInfo: nil,
    serviceType: "nearby")
  
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(UIDevice.current.identifierForVendor?.uuidString ?? "")
    
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
    
    advertiser.delegate = self
    browser.delegate = self
    session.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    browser.startBrowsingForPeers()
    advertiser.startAdvertisingPeer()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    browser.stopBrowsingForPeers()
    advertiser.stopAdvertisingPeer()
  }
  
  @objc func sendButtonTapped() {
    guard let message = entryView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty,
          let messageData = message.data(using: .utf8) else {
      return
    }
    
    try? session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
    entryView.textView.text = nil
    messages.append(message)
    tableView.reloadData()
  }
}

extension ChatController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(UITableViewCell.self)
    cell.textLabel?.text = messages[indexPath.row]
    return cell
  }
}

extension ChatController: MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peerID: MCPeerID,
    withDiscoveryInfo info: [String : String]?) {
//    advertiser.stopAdvertisingPeer()
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    
  }
  
  func advertiser(
    _ advertiser: MCNearbyServiceAdvertiser,
    didReceiveInvitationFromPeer peerID: MCPeerID,
    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//    browser.stopBrowsingForPeers()
    invitationHandler(true, session)
  }
}

extension ChatController: MCSessionDelegate {
  func session(
    _ session: MCSession,
    peer peerID: MCPeerID,
    didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("Connected: \(peerID.displayName)")
      
    case .connecting:
      print("Connecting: \(peerID.displayName)")
      
    case .notConnected:
      print("Not Connected: \(peerID.displayName)")
      
    @unknown default:
      fatalError()
    }
  }
  
  func session(
    _ session: MCSession,
    didReceive data: Data,
    fromPeer peerID: MCPeerID) {
    guard let message = String(data: data, encoding: .utf8) else { return }
    
    DispatchQueue.main.async { [self] in
      messages.append(message)
      tableView.reloadData()
    }
  }
  
  func session(
    _ session: MCSession,
    didReceive stream: InputStream,
    withName streamName: String,
    fromPeer peerID: MCPeerID) {
    
  }
  
  func session(
    _ session: MCSession,
    didStartReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID,
    with progress: Progress) {
    
  }
  
  func session(
    _ session: MCSession,
    didFinishReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID,
    at localURL: URL?,
    withError error: Error?) {
    
  }
}
