import ReSwift

extension ChatState {
  
  // MARK: - Shared Chat Reducer
  
  private static func reduceShared(action: Action, for state: inout Self?) -> Self? {
    var state = state
    
    // MARK: - Persist messages sent from/received in host chat in a database.
    switch action {
      case let action as SendMessage where action.chat.type == state?.type:
        state?.messages.insert(action.message, at: 0)
        
      case let action as ReceivedMessage where action.chatType == state?.type:
        state?.messages.insert(action.message, at: 0)
        
      default: break
    }
    
    return state
  }
  
  
  // MARK: - Host Chat Reducer
  
  static func hostChatReduce(action: Action, state: Self?) -> Self {
    var state = state
    return reduceShared(action: action, for: &state) ?? .init(host: Inject.Preferences().userProfile, type: .host)
  }
  
  
  // MARK: - Guest Chat Reducer
  
  static func guestChatReduce(action: Action, state: Self?) -> Self? {
    var state = state
    return reduceShared(action: action, for: &state)
  }
}
