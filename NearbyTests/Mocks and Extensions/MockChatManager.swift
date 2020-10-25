@testable import Nearby
import MultipeerConnectivity

class MockChatManager: ChatManagerInterface {
  
  typealias InvitationHandler = (MCPeerID, Invitation) -> Void
  typealias SendMessageHandler = (Message, ChatType) -> Void
  
  var setUpHandler: VoidClosure? = nil
  var setDiscoveringHandler: VoidClosure? = nil
  var inviteHandler: InvitationHandler? = nil
  var disconnectHandler: VoidClosure? = nil
  var sendMessageHandler: SendMessageHandler? = nil
  
  internal init(
    setUpHandler: VoidClosure? = nil,
    setDiscoveringHandler: VoidClosure? = nil,
    inviteHandler: InvitationHandler? = nil,
    disconnectHandler: VoidClosure? = nil,
    sendMessageHandler: SendMessageHandler? = nil) {
    self.setUpHandler = setUpHandler
    self.setDiscoveringHandler = setDiscoveringHandler
    self.inviteHandler = inviteHandler
    self.disconnectHandler = disconnectHandler
    self.sendMessageHandler = sendMessageHandler
  }
  
  
  // MARK: - Functions
  
  func setUpAndStartDiscovery() {
    setUpHandler?()
  }
  
  func setIsDiscovering(_ isDiscovering: Bool) {
    setDiscoveringHandler?()
  }
  
  func invite(peer: MCPeerID, invitation: Invitation) {
    inviteHandler?(peer, invitation)
  }
  
  func disconnectFromHost() {
    disconnectHandler?()
  }
  
  func sendMessage(_ message: Message, in chatType: ChatType) {
    sendMessageHandler?(message, chatType)
  }
}
