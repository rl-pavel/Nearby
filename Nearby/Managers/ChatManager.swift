import Foundation
import MultipeerConnectivity
import ReSwift

class ChatManager: NSObject {
  
  static var shared = ChatManager()
  
  var myPeerId = MCPeerID(displayName: Preferences.shared.userName)
  lazy var hostSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
  lazy var guestSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
    
  lazy var advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: "nearby")
  lazy var browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: "nearby")
  
  private override init() {
    super.init()
    
    hostSession.delegate = self
    guestSession.delegate = self
    advertiser.delegate = self
    browser.delegate = self
  }
  
  func startDiscovery() {
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }
}

extension ChatManager: MCNearbyServiceAdvertiserDelegate {
  func advertiser(
    _ advertiser: MCNearbyServiceAdvertiser,
    didReceiveInvitationFromPeer peerID: MCPeerID,
    withContext context: Data?,
    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    guard let context = context, let purpose = String(data: context, encoding: .utf8) else {
      invitationHandler(false, nil)
      return
    }
    
    if purpose == .joinRequest {
      Store.dispatch(BrowserState.Peer.invite(peerID))
      invitationHandler(false, nil)
      
    } else if purpose == .invitation {
      invitationHandler(true, guestSession)
      Store.dispatch(BrowserState.SetState(state: .invited))
      advertiser.stopAdvertisingPeer()
    }
  }
}


extension ChatManager: MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peerID: MCPeerID,
    withDiscoveryInfo info: [String : String]?) {
    Store.dispatch(BrowserState.Peer.found(peerID))
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    Store.dispatch(BrowserState.Peer.lost(peerID))
  }
}

extension ChatManager: MCSessionDelegate {
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
    
    DispatchQueue.main.async {
      Store.dispatch(ChatState.AddMessage(.init(sender: peerID.displayName, text: message)))
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
