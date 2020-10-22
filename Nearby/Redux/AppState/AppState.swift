import Foundation
import ReSwift
import MultipeerConnectivity

var Store = ReSwift.Store(
  reducer: AppState.reduce,
  state: AppState(),
  middleware: [
    Middleware.create(AppState.middleware()),
    Middleware.create(BrowserState.middleware()),
    Middleware.create(ChatState.middleware())
  ]
)


struct AppState: StateType {
  
  // MARK: - Properties
  
  var browser = BrowserState()
  
  var hostChat = Preferences.shared.chatHistory ?? ChatState(host: Preferences.shared.userProfile)
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
