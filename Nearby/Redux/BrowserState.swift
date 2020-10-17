import ReSwift
import MultipeerConnectivity

struct BrowserState: StateType {
  
  // MARK: - Properties
  
  var nearbyChats = [ChatState]()
  
  
  // MARK: - Actions
  
  enum Connection: Action {
    case found(MCPeerID)
    case lost(MCPeerID)
  }
  
  enum Invite: Action {
    case send(to: MCPeerID, Invitation)
    case received(from: MCPeerID, Invitation, InvitationHandler)
  }

  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: StateContext) -> Action? {
    let chatManager = ChatManager.shared
    
    switch action {
      case let .received(from: peer, invitation, invitationHandler) as Invite:
        if invitation.purpose == .joinRequest {
          // Host side - reject the request, it will be sent back as an invite.
          invitationHandler(false, nil)
          
          let messageHistory = context.state?.hostChat.messages
          context.dispatch(Invite.send(to: peer, Invitation(purpose: .confirmation, messageHistory: messageHistory)))
          
        } else {
          // Guest side - accept the invitation from the host.
          invitationHandler(true, chatManager.guestSession.session)
          
          let newChat = ChatState(host: peer, messages: invitation.messageHistory ?? [])
          context.next(ChatState.SetGuestChat(chat: newChat))
        }
        
      case let .send(to: peer, invitation) as Invite:
        guard let context = try? JSONEncoder().encode(invitation) else { break }
        chatManager.browser.invitePeer(
          peer,
          to: chatManager.hostSession.session,
          withContext: context,
          timeout: Constants.invitationTimeout)
        
      default: break
    }
    
    return action
  }
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var browser = state ?? .init()
    
    switch action {
      case .found(let host) as Connection:
        browser.nearbyChats.append(.init(host: host))
        
      case .lost(let host) as Connection:
        browser.nearbyChats.removeAll { $0.host == host }
        
      default:
        break
    }
    
    return browser
  }
}
