import ReSwift
import MultipeerConnectivity

// MARK: -  State

struct BrowserState: StateType {
  enum State {
    case browsing
    case invited
  }
  
  var peers = [MCPeerID]()
  var state = State.browsing
}


// MARK: - State Management

extension BrowserState {
  
  // MARK: - Actions
  
  // TODO: - Improve naming.
  enum Peer: Action {
    case found(MCPeerID)
    case lost(MCPeerID)
    
    case join(MCPeerID)
    case invite(MCPeerID)
  }
  
  struct SetState: Action {
    let state: State
  }

  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: StateContext) -> Action? {
    let chatManager = ChatManager.shared
    
    switch action {
      case .join(let peer) as Peer:
        let purpose = "joinRequest".data(using: .utf8)
        chatManager.browser.invitePeer(
          peer,
          to: chatManager.guestSession,
          withContext: purpose,
          timeout: .invitationTimeout)
        
      case .invite(let peer) as Peer:
        let purpose = "invitation".data(using: .utf8)
        chatManager.browser.invitePeer(
          peer,
          to: chatManager.hostSession,
          withContext: purpose,
          timeout: .invitationTimeout)
        
      default: break
    }
    
    return action
  }
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var browser = state ?? .init()
    
    switch action {
      case .found(let peer) as Peer:
        browser.peers.append(peer)
        
      case .lost(let peer) as Peer:
        browser.peers.removeAll { $0 == peer }
        
      case let action as SetState:
        browser.state = action.state
        browser.peers.removeAll()
        
      default:
        break
    }
    
    return browser
  }
}
