import ReSwift

extension ChatState {
  static func middleware(action: Action, context: StateContext) -> Action? {
    let chatManager = ChatManager.shared
    let state = context.state
    
    switch action {
      case let action as SendMessage:
        guard let chat = state?.guestChat ?? state?.hostChat else {
          fatalError("Message sent without a chat? 🤔")
        }
        
        chatManager.sendMessage(action.message, to: chat.host)
        
      default: break
    }
    
    return action
  }
}
