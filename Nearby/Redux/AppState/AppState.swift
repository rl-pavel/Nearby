import Foundation
import ReSwift
import MultipeerConnectivity

struct AppState: StateType {
  
  // MARK: - Properties
  
  var browser = BrowserState()
  
  var hostChat = ChatState(host: DI.Preferences().userProfile)
  var guestChat: ChatState?
}


// MARK: - Actions

extension AppState {
  struct UpdateProfile: Action {
    var avatar: UIImage?
    var name: String
    var peerId: MCPeerID = .devicePeerId
  }
}
