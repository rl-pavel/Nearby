import ReSwift

extension BrowserState {
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: MiddlewareContext) -> Action {
    let state = context.state
    let chatManager = DI.ChatManager()
    
    switch action {
      case let .send(to: peer, invitation) as Invite:
        chatManager.invite(peer: peer, to: .host, invitation: invitation)
        
      case let .received(invitation, invitationHandler, _) as Invite
            where invitation.purpose == .joinRequest:
        // Host side - reject the request, it will be sent back as an invite to join the host's session.
        invitationHandler(false, nil)
        
        let confirmation = Invitation(purpose: .confirmation, messageHistory: state?.hostChat.messages)
        context.dispatch(Invite.send(to: invitation.profile.peerId, confirmation))
        
      case let .received(invitation, invitationHandler, session) as Invite
            where invitation.purpose == .confirmation:
        // Guest side - accept the invitation to join the host.
        invitationHandler(true, session)
        
        let newChat = ChatState(host: invitation.profile, messages: invitation.messageHistory ?? [])
        context.next(ChatState.SetGuestChat(chat: newChat))
        
      default: break
    }
    
    return action
  }
}
