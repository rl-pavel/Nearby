import ReSwift

extension BrowserState {
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var browser = state ?? .init()
    
    switch action {
      case .found(let profile) as Connection:
        guard !browser.chats.contains(where: { $0.host == profile }) else { break }
        browser.chats.append(.init(host: profile))
        
      case .lost(let peer) as Connection:
        browser.chats.removeAll { $0.host.peerId == peer }
        
      case .reset as Connection:
        browser.chats.removeAll()
        
      default:
        break
    }
    
    return browser
  }
}
