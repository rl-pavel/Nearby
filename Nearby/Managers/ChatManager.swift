import Foundation
import MultipeerConnectivity
import ReSwift

typealias InvitationHandler = (Bool, MCSession?) -> Void

class SessionClient: NSObject {
  
  enum SessionType {
    case host, guest
  }
  
  var type: SessionType
  let session: MCSession
  
  init(type: SessionType, myPeerId: MCPeerID) {
    self.type = type
    self.session = .init(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
    
    super.init()
    
    session.delegate = self
  }
}

extension SessionClient: MCSessionDelegate {
  func session(
    _ session: MCSession,
    peer: MCPeerID,
    didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("Connected: \(peer.displayName)")
      
    case .connecting:
      print("Connecting: \(peer.displayName)")
      
    case .notConnected:
      print("Not Connected: \(peer.displayName)")
      
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


// MARK: - ChatManager

class ChatManager: NSObject {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  var userPeer = MCPeerID(displayName: Preferences.shared.userName)
  lazy var hostSession = SessionClient(type: .host, myPeerId: userPeer)
  lazy var guestSession = SessionClient(type: .guest, myPeerId: userPeer)
    
  lazy var advertiser = MCNearbyServiceAdvertiser(peer: userPeer, discoveryInfo: nil, serviceType: "nearby")
  lazy var browser = MCNearbyServiceBrowser(peer: userPeer, serviceType: "nearby")
  
  
  // MARK: - Inits
  
  private override init() {
    super.init()

    advertiser.delegate = self
    browser.delegate = self
    
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }
  
  
  // MARK: - Functions
  
  func sendMessage(_ message: Message, to peer: MCPeerID) {
    guard let messageData = try? message.encoded() else { return }
    let session = peer == userPeer ? hostSession.session : guestSession.session
    
    do {
      try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
      
    } catch let error {
      // TODO: - Show error to user?
      fatalError("Failed to send message with error: \(error)")
    }
  }
}

extension ChatManager: MCNearbyServiceAdvertiserDelegate {
  func advertiser(
    _ advertiser: MCNearbyServiceAdvertiser,
    didReceiveInvitationFromPeer peer: MCPeerID,
    withContext context: Data?,
    invitationHandler: @escaping InvitationHandler) {
    guard let data = context, let invitation = try? Invitation.decode(from: data) else {
      invitationHandler(false, nil)
      return
    }
    
    Store.dispatch(BrowserState.Invite.received(from: peer, invitation, invitationHandler))
  }
}


extension ChatManager: MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peer: MCPeerID,
    withDiscoveryInfo info: [String : String]?) {
    Store.dispatch(BrowserState.Connection.found(peer))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peer: MCPeerID) {
    Store.dispatch(BrowserState.Connection.lost(peer))
  }
}
