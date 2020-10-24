import ReSwift

extension ChatState {
  
  // MARK: - Host Chat Reducer
  
  static func hostChatReduce(action: Action, state: Self?) -> Self {
    var chatState = state ?? .init(host: DI.Preferences().userProfile)
    // TODO: - Move to AppDelegate to only store the chat when the app closes.
    defer {
      DI.Preferences().chatHistory = chatState
    }
    
    switch action {
      case let action as SendMessage where action.chat.host == chatState.host:
        chatState.messages.insert(action.message, at: 0)
        
      // Only handle received messages for the appropriate session (i.e. don't add a received message in the host
      // chat if it was received in the guest session).
      case let action as ReceivedMessage where action.sessionType == .host:
        chatState.messages.insert(action.message, at: 0)
        
      default: break
    }
    
    return chatState
  }
  
  
  // MARK: - Guest Chat Reducer
  
  static func guestChatReduce(action: Action, state: Self?) -> Self? {
    var chatState = state
    
    switch action {
      case let action as SetGuestChat:
        return action.chat
        
      case let action as SendMessage where action.chat.host == chatState?.host:
        chatState?.messages.insert(action.message, at: 0)
        
      // Only handle received messages for the appropriate session (i.e. don't add a received message in the guest
      // chat if it was received in the host session).
      case let action as ReceivedMessage where action.sessionType == .guest:
        chatState?.messages.insert(action.message, at: 0)
        
      case .lost(let peer) as BrowserState.Connection where peer == chatState?.host.peerId:
        chatState = nil
        
      default: break
    }
    
    return chatState
  }
}
