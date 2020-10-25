import ReSwift

extension AppState {
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: MiddlewareContext) -> Action {
    let preferences = Inject.Preferences()
    let chatManager = Inject.ChatManager()
    
    switch action {
      case let action as UpdateProfile:
        // TODO: - Allow removing the avatar somehow?
        action.avatar.map { preferences.userProfile.avatar = $0 }
        
        preferences.userProfile.name = action.name
        // Change the instance of the MCPeerID and restart discovery so other devices get the updated profile.
        preferences.userProfile.peerId = action.peerId
        chatManager.setUpAndStartDiscovery()
        
      case let action as SetGuestChat where action.chat == nil:
        chatManager.disconnectFromHost()
        
      default: break
    }
    
    return action
  }
}
