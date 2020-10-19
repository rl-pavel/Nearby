import ReSwift

extension ChatState {
  static func middleware(chatManager: ChatManager = .shared) -> MiddlewareHandler {
    return { action, context in
      let state = context.state
      
      switch action {
        case let action as SendMessage:
          guard let chat = state?.guestChat ?? state?.hostChat else {
            fatalError("Message sent without a chat? 🤔")
          }
          
          chatManager.sendMessage(action.message, to: chat.host)
          
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
