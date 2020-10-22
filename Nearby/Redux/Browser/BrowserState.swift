import ReSwift
import MultipeerConnectivity

struct BrowserState: StateType {
  
  // MARK: - Properties
  
  var chats = [ChatState]()
}


// MARK: - Actions

extension BrowserState {
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
