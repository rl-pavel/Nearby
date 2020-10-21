import Foundation
import MultipeerConnectivity
import ReSwift

typealias InvitationHandler = (Bool, MCSession?) -> Void

class ChatManager: NSObject {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  var userPeerId: MCPeerID { Preferences.shared.userProfile.peerId }
  
  private lazy var hostClient = ChatClient(type: .host, myPeerId: userPeerId)
  private lazy var guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
    
  private lazy var advertiser = MCNearbyServiceAdvertiser(
    peer: userPeerId,
    discoveryInfo: ["userName": Preferences.shared.userProfile.name],
    serviceType: "nearby")
  private lazy var browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: "nearby")
  
  private var discoveryAttempts = 0
  
  
  // MARK: - Inits
  
  private override init() {
    super.init()
    
    advertiser.delegate = self
    browser.delegate = self
    
    startDiscovery()
  }
  
  
  // MARK: - Functions
  
  func setUpAndStartDiscovery() {
    stopDiscovery()
    
    hostClient = ChatClient(type: .host, myPeerId: userPeerId)
    guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
    
    advertiser = MCNearbyServiceAdvertiser(
      peer: userPeerId,
      discoveryInfo: ["userName": Preferences.shared.userProfile.name],
      serviceType: "nearby")
    advertiser.delegate = self
    
    browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: "nearby")
    browser.delegate = self
    
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
    foundPeer peerId: MCPeerID,
    withDiscoveryInfo info: [String : String]?) {
    guard let userName = info?["userName"] else { return }
    let profile = Profile(peerId: peerId, userName: userName)
    
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
