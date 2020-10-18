import ReSwift
import MultipeerConnectivity

struct BrowserState: StateType {
  
  // MARK: - Properties
  
  var chats = [ChatState]()
  
  
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
      case let .send(to: peer, invitation) as Invite:
        guard let context = try? invitation.encoded() else { break }
        chatManager.browser.invitePeer(
          peer,
          to: chatManager.hostClient.session,
          withContext: context,
          timeout: Constants.invitationTimeout)
        
      case let .received(from: peer, invitation, invitationHandler) as Invite
            where invitation.purpose == .joinRequest:
        // Host side - reject the request, it will be sent back as an invite to join the host's session.
        invitationHandler(false, nil)
        
        let confirmation = Invitation(purpose: .confirmation, messageHistory: context.state?.hostChat.messages)
        context.dispatch(Invite.send(to: peer, confirmation))
        
      case let .received(from: peer, invitation, invitationHandler) as Invite
            where invitation.purpose == .confirmation:
        // Guest side - accept the invitation to join the host.
        invitationHandler(true, chatManager.guestClient.session)
        
        let newChat = ChatState(host: peer, messages: invitation.messageHistory ?? [])
        context.next(ChatState.SetGuestChat(chat: newChat))
        
      default: break
    }
    
    return action
  }
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var browser = state ?? .init()
    
    switch action {
      case .found(let peer) as Connection:
        browser.chats.append(.init(host: peer))
        
      case .lost(let peer) as Connection:
        browser.chats.removeAll { $0.host == peer }
        
      default:
        break
    }
    
    return browser
  }
}
