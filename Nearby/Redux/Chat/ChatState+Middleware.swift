import ReSwift

extension ChatState {
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: MiddlewareContext) -> Action {
    let state = context.state
    let chatManager = DI.ChatManager()
    
    switch action {
      case let action as SendMessage:
        guard let chat = state?.guestChat ?? state?.hostChat else {
          fatalError("Message sent without a chat? 🤔")
        }
        
        // TODO: - Don't send the avatar in every message sender's profile.
        chatManager.sendMessage(action.message, to: chat.host.peerId)
        
      case let action as SetGuestChat:
        if action.chat == nil {
          chatManager.disconnectFromHost()
        }
        
      default: break
    }
    
    return action
  }
}
