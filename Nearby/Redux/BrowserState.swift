import ReSwift
import MultipeerConnectivity

struct BrowserState: StateType {
  
  // MARK: - Properties
  
  var chats = [ChatState]()
  
  
  // MARK: - Actions
  
  enum Connection: Action {
    case found(MCPeerID)
    case lost(MCPeerID)
    case reset
  }
  
  enum Invite: Action {
    case send(to: MCPeerID, Invitation)
    case received(from: MCPeerID, Invitation, InvitationHandler, MCSession)
  }
  
  
  // MARK: - Middleware
  
  static func middleware(chatManager: ChatManager = .shared) -> MiddlewareHandler {
    return { action, context in
      switch action {
        case let .send(to: peer, invitation) as Invite:
          ChatManager.shared.invite(peer: peer, to: .host, invitation: invitation)
          
        case let .received(from: peer, invitation, invitationHandler, _) as Invite
              where invitation.purpose == .joinRequest:
          // Host side - reject the request, it will be sent back as an invite to join the host's session.
          invitationHandler(false, nil)
          
          let confirmation = Invitation(purpose: .confirmation, messageHistory: context.state?.hostChat.messages)
          context.dispatch(Invite.send(to: peer, confirmation))
          
        case let .received(from: peer, invitation, invitationHandler, session) as Invite
              where invitation.purpose == .confirmation:
          // Guest side - accept the invitation to join the host.
          invitationHandler(true, session)
          
          let newChat = ChatState(host: peer, messages: invitation.messageHistory ?? [])
          context.next(ChatState.SetGuestChat(chat: newChat))
          
        case .reset as Connection:
          chatManager.stopDiscovery()
          context.next(action)
          chatManager.startDiscovery()
          return nil
          
        default: break
      }
      
      return action
    }
  }
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var browser = state ?? .init()
    
    switch action {
      case .found(let peer) as Connection:
        guard !browser.chats.contains(where: { $0.host == peer }) else { break }
          browser.chats.append(.init(host: peer))
        
      case .lost(let peer) as Connection:
        browser.chats.removeAll { $0.host == peer }
        
      case .reset as Connection:
        browser.chats.removeAll()
        
      default:
        break
    }
    
    return browser
  }
}
