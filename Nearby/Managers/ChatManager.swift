import Foundation
import MultipeerConnectivity
import ReSwift

// MARK: - ChatManager Interface

protocol ChatManagerInterface: AnyObject {
  func setUpAndStartDiscovery()
  func setIsDiscovering(_ isDiscovering: Bool)
  func invite(peer: MCPeerID, invitation: Invitation)
  func disconnectFromHost()
  func sendMessage(_ message: Message, in chatType: ChatType)
}

extension Inject {
  static let ChatManager = bind(ChatManagerInterface.self) { Nearby.ChatManager.shared }
}


// MARK: - ChatManager Implementation

private class ChatManager: NSObject, ChatManagerInterface {
  
  // MARK: - Properties
  
  static var shared = ChatManager()
  
  private var userPeerId: MCPeerID {
    return Inject.Preferences().userProfile.peerId
  }
  
  private lazy var hostClient = ChatClient(type: .host, myPeerId: userPeerId)
  private lazy var guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
  
  private lazy var advertiser = MCNearbyServiceAdvertiser(
    peer: userPeerId,
    discoveryInfo: [Constants.userNameKey: Inject.Preferences().userProfile.name],
    serviceType: Constants.nearbyService)
  private lazy var browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: Constants.userNameKey)
  
  private var discoveryAttempts = 0
  
  
  // MARK: - Inits
  
  private override init() {
    super.init()
  }
  
  
  // MARK: - Functions
  
  func setUpAndStartDiscovery() {
    setIsDiscovering(false)
    
    hostClient = ChatClient(type: .host, myPeerId: userPeerId)
    guestClient = ChatClient(type: .guest, myPeerId: userPeerId)
    
    advertiser = MCNearbyServiceAdvertiser(
      peer: userPeerId,
      discoveryInfo: [Constants.userNameKey: Inject.Preferences().userProfile.name],
      serviceType: Constants.nearbyService)
    advertiser.delegate = self
    
    browser = MCNearbyServiceBrowser(peer: userPeerId, serviceType: Constants.nearbyService)
    browser.delegate = self
    
    setIsDiscovering(true)
  }
  
  func setIsDiscovering(_ isDiscovering: Bool) {
    if isDiscovering {
      advertiser.startAdvertisingPeer()
      browser.startBrowsingForPeers()
      
    } else {
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
    }
  }
  
  func invite(peer: MCPeerID, invitation: Invitation) {
    // Invitations are sent from the host session by default.
    browser.invitePeer(
      peer,
      to: hostClient.session,
      withContext: try? invitation.encoded(),
      timeout: Constants.invitationTimeout)
  }
  
  func disconnectFromHost() {
    guestClient.session.disconnect()
  }
  
  func sendMessage(_ message: Message, in chatType: ChatType) {
    let session = chatType == .host ? hostClient.session : guestClient.session
    
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
    Inject.Store().dispatch(BrowserState.Invite.received(invitation, invitationHandler, guestClient.session))
  }
  
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    guard discoveryAttempts < 5 else {
      // TODO: - Show error to user.
      assert(false, "Could not start advertising.")
      return
    }
    
    print("🔴 Failed to start advertising - trying again.")
    setIsDiscovering(true)
  }
}


// MARK: - Browser Delegate

extension ChatManager: MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peerId: MCPeerID,
    withDiscoveryInfo info: [String: String]?) {
    Inject.Store().dispatch(BrowserState.Connection.found(peerId, into: info))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peer: MCPeerID) {
    Inject.Store().dispatch(BrowserState.Connection.lost(peer))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    guard discoveryAttempts < 5 else {
      // TODO: - Show error to user.
      assert(false, "Could not start advertising.")
      return
    }
    
    print("🔴 Failed to start browsing - trying again.")
    setIsDiscovering(true)
  }
}
