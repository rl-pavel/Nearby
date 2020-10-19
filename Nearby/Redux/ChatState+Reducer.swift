import ReSwift

extension ChatState {
  static func hostChatReduce(action: Action, state: Self?) -> Self {
    var chatState = state ?? .init(host: ChatManager.shared.userPeer)
    
    switch action {
      case let action as SendMessage where action.chat.host == chatState.host:
        chatState.messages.append(action.message)
        
      // Only handle received messages for the appropriate session (i.e. don't add a received message in the host
      // chat if it was received in the guest session).
      case let action as ReceivedMessage where action.sessionType == .host:
        chatState.messages.append(action.message)
        
      default: break
    }
    
    return chatState
  }
  
  static func guestChatReduce(action: Action, state: Self?) -> Self? {
    var chatState = state
    
    switch action {
      case let action as SetGuestChat:
        return action.chat
        
      case let messageAction as SendMessage where messageAction.belongs(to: chatState?.host):
        chatState?.messages.append(messageAction.message)
        
      // Only handle received messages for the appropriate session (i.e. don't add a received message in the guest
      // chat if it was received in the host session).
      case let action as ReceivedMessage where action.sessionType == .guest:
        chatState?.messages.append(action.message)
        
      case .lost(let peer) as BrowserState.Connection where peer == chatState?.host:
        chatState = nil
        
      default: break
    }
    
    return chatState
  }
}
