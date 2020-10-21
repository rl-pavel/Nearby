import ReSwift
import MultipeerConnectivity

extension BrowserState {
  
  // MARK: - Actions
  
  enum Connection: Action {
    case found(Profile)
    case lost(MCPeerID)
    case reset
  }
  
  enum Invite: Action {
    case send(to: MCPeerID, Invitation)
    case received(Invitation, InvitationHandler, MCSession)
  }
}
