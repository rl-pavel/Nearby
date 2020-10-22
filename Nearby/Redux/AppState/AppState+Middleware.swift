import Foundation

extension AppState {
  
  // MARK: - Middleware
  
  static func middleware(
    preferences: Preferences = .shared,
    chatManager: ChatManager = .shared) -> MiddlewareHandler {
    return { action, context in
      
      switch action {
        case let action as UpdateProfile:
          action.avatar.map { preferences.userProfile.avatar = $0 }
          preferences.userProfile.name = action.name
          // Change the instance of the MCPeerID and restart discovery so other devices get the updated profile.
          preferences.userProfile.peerId = action.peerId
          chatManager.setUpAndStartDiscovery()
          
        default: break
      }
      
      return action
    }
  }
}
