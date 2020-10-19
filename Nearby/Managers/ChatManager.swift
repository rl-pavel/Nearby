import Foundation
import MultipeerConnectivity
import ReSwift

typealias InvitationHandler = (Bool, MCSession?) -> Void

class ChatManager: NSObject {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  var userPeer = MCPeerID(displayName: Preferences.shared.userName)
  
  lazy var hostClient = ChatClient(type: .host, myPeerId: userPeer)
  lazy var guestClient = ChatClient(type: .guest, myPeerId: userPeer)
    
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
    let session = peer == userPeer ? hostClient.session : guestClient.session
    
    do {
      try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
      
    } catch let error {
      // TODO: - When does this fail? Show error to user?
      fatalError("Failed to send message with error: \(error)")
    }
  }
}


// MARK: - Advertiser Delegate

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


// MARK: - Browser Delegate

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
