import Foundation
import ReSwift
import MultipeerConnectivity

struct AppState: StateType {
  
  // MARK: - Properties
  
  var browser = BrowserState()
  
  var hostChat = ChatState(host: Inject.Preferences().userProfile, type: .host)
  var guestChat: ChatState?
}


// MARK: - Actions

extension AppState {
  struct SetGuestChat: Action {
    let chat: ChatState?
  }
  
  struct UpdateProfile: Action {
    var avatar: UIImage?
    var name: String
    var peerId: MCPeerID = .devicePeerId
  }
}
