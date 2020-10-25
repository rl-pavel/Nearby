import ReSwift

extension BrowserState {
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var state = state ?? .init()
    
    switch action {
      case let .found(peerId, discoveryInfo) as Connection:
        let userName = discoveryInfo?[Constants.userNameKey] ?? "Unknown User"
        let profile = Profile(peerId: peerId, userName: userName)
        let profileExists = state.chats.contains { $0.host == profile }
        
        if !profileExists {
          state.chats.append(ChatState(host: profile, type: .guest))
        }

      case .lost(let peer) as Connection:
        state.chats.removeAll { $0.host.peerId == peer }
        
      case .reset as Connection:
        state = BrowserState()
        
      default:
        break
    }
    
    return state
  }
}
