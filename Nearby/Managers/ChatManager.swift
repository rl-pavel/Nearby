import Foundation
import MultipeerConnectivity
import ReSwift

typealias InvitationHandler = (Bool, MCSession?) -> Void

class ChatManager: NSObject {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  lazy var userPeerId = Preferences.shared.userProfile.peerId
  
  private lazy var hostClient = ChatClient(type: .host, myPeerId: userPeerId)
  private lazy var guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
    
  private lazy var advertiser = MCNearbyServiceAdvertiser(peer: userPeerId, discoveryInfo: nil, serviceType: "nearby")
  private lazy var browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: "nearby")
  
  private var discoveryAttempts = 0
  
  
  // MARK: - Inits
  
  private override init() {
    super.init()
    
    setUpAndStartDiscovery(with: userPeerId)
  }
  
  
  // MARK: - Functions
  
  func setUpAndStartDiscovery(with newPeerId: MCPeerID) {
    stopDiscovery()
    
    userPeerId = newPeerId
    _hostClient = ChatClient(type: .host, myPeerId: userPeerId)
    _guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
    
    _advertiser = MCNearbyServiceAdvertiser(peer: userPeerId, discoveryInfo: nil, serviceType: "nearby")
    _advertiser.delegate = self
    
    _browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: "nearby")
    _browser.delegate = self
    
    startDiscovery()
  }
  
  func startDiscovery() {
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }
  
  func stopDiscovery() {
    advertiser.stopAdvertisingPeer()
    browser.stopBrowsingForPeers()
  }
  
  func invite(peer: MCPeerID, to sessionType: ChatClient.SessionType, invitation: Invitation) {
    let session = sessionType == .host ? hostClient.session : guestClient.session
    
    browser.invitePeer(
      peer,
      to: session,
      withContext: try? invitation.encoded(),
      timeout: Constants.invitationTimeout)
  }
  
  func disconnectFromHost() {
    guestClient.session.disconnect()
  }
  
  func sendMessage(_ message: Message, to peer: MCPeerID) {
    let session = peer == userPeerId ? hostClient.session : guestClient.session
    
    guard let messageData = try? message.encoded(),
          let peers = session.connectedPeers.nonEmpty else {
      return
    }
    
    do {
      try session.send(messageData, toPeers: peers, with: .reliable)
      
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
    
    // Invitations are only accepted as a guest, so use the guest client's session by default.
    Store.dispatch(BrowserState.Invite.received(invitation, invitationHandler, guestClient.session))
  }
  
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    guard discoveryAttempts < 5 else {
      // TODO: - Show error to user.
      return
    }
    
    print("🔴 Failed to start advertising - trying again.")
    startDiscovery()
  }
}


// MARK: - Browser Delegate

extension ChatManager: MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peer: MCPeerID,
    withDiscoveryInfo info: [String : String]?) {
    let profile = Profile(peerId: peer)
    
    Store.dispatch(BrowserState.Connection.found(profile))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peer: MCPeerID) {
    Store.dispatch(BrowserState.Connection.lost(peer))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    guard discoveryAttempts < 5 else {
      // TODO: - Show error to user.
      return
    }
    
    print("🔴 Failed to start browsing - trying again.")
    startDiscovery()
  }
}
