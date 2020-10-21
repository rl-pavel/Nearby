import ReSwift

extension ChatState {
  
  // MARK: - Middleware
  
  static func middleware(chatManager: ChatManager = .shared) -> MiddlewareHandler {
    return { action, context in
      let state = context.state
      
      switch action {
        case let action as SendMessage:
          var message = action.message
          guard let chat = state?.guestChat ?? state?.hostChat else {
            fatalError("Message sent without a chat? 🤔")
          }
          
          // Don't send the avatar in message sender's profile to save performance.
          message.sender.avatar = nil
          
          chatManager.sendMessage(message, to: chat.host.peerId)
          
        case let action as SetGuestChat:
          if action.chat == nil {
            chatManager.disconnectFromHost()
          }
          
        default: break
      }
      
      return action
    }
  }
}
