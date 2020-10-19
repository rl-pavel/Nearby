import Foundation
import MultipeerConnectivity
import ReSwift

typealias InvitationHandler = (Bool, MCSession?) -> Void

class ChatManager: NSObject {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  lazy var userPeer = Preferences.shared.userPeer {
    willSet {
      // Whenever the user peer is changed (e.g. after rename), make sure the
      // sessions, advertiser and browser are updated.
      Preferences.shared.userPeer = newValue
      _setUpAndStartDiscovery(with: newValue)
    }
  }
  
  private lazy var _hostClient = ChatClient(type: .host, myPeerId: userPeer)
  private lazy var _guestClient = ChatClient(type: .guest, myPeerId: userPeer)
    
  private lazy var _advertiser = MCNearbyServiceAdvertiser(peer: userPeer, discoveryInfo: nil, serviceType: "nearby")
  private lazy var _browser = MCNearbyServiceBrowser(peer: userPeer, serviceType: "nearby")
  
  private var _discoveryAttempts = 0
  
  
  // MARK: - Inits
  
  private override init() {
    super.init()
    
    _setUpAndStartDiscovery(with: userPeer)
  }
  
  
  // MARK: - Functions
  
  func startDiscovery() {
    _advertiser.startAdvertisingPeer()
    _browser.startBrowsingForPeers()
  }
  
  func stopDiscovery() {
    _advertiser.stopAdvertisingPeer()
    _browser.stopBrowsingForPeers()
  }
  
  func invite(peer: MCPeerID, to sessionType: ChatClient.SessionType, invitation: Invitation) {
    let session = sessionType == .host ? _hostClient.session : _guestClient.session
    
    _browser.invitePeer(
      peer,
      to: session,
      withContext: try? invitation.encoded(),
      timeout: Constants.invitationTimeout)
  }
  
  func disconnectFromHost() {
    _guestClient.session.disconnect()
  }
  
  func sendMessage(_ message: Message, to peer: MCPeerID) {
    let session = peer == userPeer ? _hostClient.session : _guestClient.session
    
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
    Store.dispatch(BrowserState.Invite.received(from: peer, invitation, invitationHandler, _guestClient.session))
  }
  
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    guard _discoveryAttempts < 5 else {
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
    Store.dispatch(BrowserState.Connection.found(peer))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peer: MCPeerID) {
    Store.dispatch(BrowserState.Connection.lost(peer))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    guard _discoveryAttempts < 5 else {
      // TODO: - Show error to user.
      return
    }
    
    print("🔴 Failed to start browsing - trying again.")
    startDiscovery()
  }
}


// MARK: - Helper Functions

private extension ChatManager {
  func _setUpAndStartDiscovery(with newPeer: MCPeerID) {
    stopDiscovery()
    
    _hostClient = ChatClient(type: .host, myPeerId: newPeer)
    _guestClient = ChatClient(type: .guest, myPeerId: newPeer)
    
    _advertiser = MCNearbyServiceAdvertiser(peer: newPeer, discoveryInfo: nil, serviceType: "nearby")
    _advertiser.delegate = self
    
    _browser = MCNearbyServiceBrowser(peer: newPeer, serviceType: "nearby")
    _browser.delegate = self
    
    startDiscovery()
  }
}
