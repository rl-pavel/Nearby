import ReSwift

extension ChatState {
  static func hostChatReduce(action: Action, state: Self?) -> Self {
    var state = state ?? .init(host: ChatManager.shared.userPeer)
    
    switch action {
      case let action as ReceivedMessage where action.sessionType == .host:
        state.messages.append(action.message)
        
      case let action as SendMessage where action.chat.host == state.host:
        state.messages.append(action.message)
        
      default: break
    }
    
    return state
  }
  
  static func guestChatReduce(action: Action, state: Self?) -> Self? {
    var state = state
    
    switch action {
      case let action as SetGuestChat:
        return action.chat
        
      case let action as ReceivedMessage where action.sessionType == .guest:
        state?.messages.append(action.message)
        
      case let action as SendMessage where action.chat.host == state?.host:
        state?.messages.append(action.message)
        
      default: break
    }
    
    return state
  }
}
