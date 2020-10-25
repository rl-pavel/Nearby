import ReSwift

extension ChatState {
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: MiddlewareContext) -> Action {
    let chatManager = Inject.ChatManager()
    
    switch action {
      case let action as SendMessage:
        // TODO: - Don't send the avatar in every message sender's profile.
        chatManager.sendMessage(action.message, in: action.chat.type)
        
      default: break
    }
    
    return action
  }
}
