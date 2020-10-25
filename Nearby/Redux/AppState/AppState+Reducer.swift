import ReSwift

extension AppState {
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: AppState?) -> AppState {
    var state = AppState(
      browser: BrowserState.reduce(action: action, state: state?.browser),
      hostChat: ChatState.hostChatReduce(action: action, state: state?.hostChat),
      guestChat: ChatState.guestChatReduce(action: action, state: state?.guestChat))
    
    switch action {
      case let action as SetGuestChat where action.chat == nil || action.chat?.type == .guest:
        state.guestChat = action.chat
      
      case let action as UpdateProfile:
        state.hostChat.host.avatar = action.avatar
        state.hostChat.host.name = action.name
        state.hostChat.host.peerId = action.peerId
      
      case let .lost(peer) as BrowserState.Connection where peer == state.guestChat?.host.peerId:
        state.guestChat = nil
        
      default: break
    }
    
    return state
  }
}
