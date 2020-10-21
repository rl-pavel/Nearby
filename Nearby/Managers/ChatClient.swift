import MultipeerConnectivity

class ChatClient: NSObject {
  
  // MARK: - Enumerations
  
  enum SessionType {
    case host, guest
  }
  
  
  // MARK: - Properties
  
  var type: SessionType
  let session: MCSession
  
  
  // MARK: - Inits
  
  init(type: SessionType, myPeerId: MCPeerID) {
    self.type = type
    self.session = .init(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
    
    super.init()
    
    session.delegate = self
  }
}


// MARK: - MCSessionDelegate Functions

extension ChatClient: MCSessionDelegate {
  func session(
    _ session: MCSession,
    peer: MCPeerID,
    didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("Connected: \(peer.id)")
      
    case .connecting:
      print("Connecting: \(peer.id)")
      
    case .notConnected:
      print("Not Connected: \(peer.id)")
      
    @unknown default:
      fatalError()
    }
  }
  
  func session(
    _ session: MCSession,
    didReceive data: Data,
    fromPeer peer: MCPeerID) {
    guard let message = try? Message.decode(from: data) else { return }
    
    DispatchQueue.main.async { [self] in
      Store.dispatch(ChatState.ReceivedMessage(message: message, sessionType: type))
    }
  }
  
  
  // MARK: - Unused Functions
  
  func session(
    _ session: MCSession,
    didReceive stream: InputStream,
    withName streamName: String,
    fromPeer peer: MCPeerID) {
    
  }
  
  func session(
    _ session: MCSession,
    didStartReceivingResourceWithName resourceName: String,
    fromPeer peer: MCPeerID,
    with progress: Progress) {
    
  }
  
  func session(
    _ session: MCSession,
    didFinishReceivingResourceWithName resourceName: String,
    fromPeer peer: MCPeerID,
    at localURL: URL?,
    withError error: Error?) {
    
  }
}

