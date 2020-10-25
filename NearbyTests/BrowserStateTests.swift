@testable import Nearby
import MultipeerConnectivity
import XCTest

class BrowserStateTests: XCTestCase {
  func testBrowserConnection() {
    setUpDefaultMocks()
    
    let userName = UUID().uuidString
    let peerId = MCPeerID.mock()
    var browserState: BrowserState { Inject.Store().state.browser }
    
    Inject.Store().dispatch(BrowserState.Connection.found(peerId, into: [Constants.userNameKey: userName]))
    
    XCTAssert(
      browserState.chats.count == 1,
      "BrowserState.chats expected to have 1 discovered chat.")
    XCTAssert(
      browserState.chats.contains { $0.host.peerId == peerId },
      "BrowserState.chats expected to contain a host with a discovered peerId.")
    XCTAssert(
      browserState.chats.contains { $0.host.name == userName },
      "BrowserState.chats expected to contain a host with a discovered name.")
    
    Inject.Store().dispatch(BrowserState.Connection.found(peerId, into: [Constants.userNameKey: userName]))
    
    XCTAssert(
      browserState.chats.count == 1,
      "BrowserReducer expected to ignore a repeat discovery.")
    
    Inject.Store().dispatch(BrowserState.Connection.lost(peerId))
    
    XCTAssert(
      browserState.chats.isEmpty,
      "BrowserState.chats expected to be empty after a lost peer.")
  }
  
  func testInvitationSent() {
    setUpDefaultMocks()
    let invitationExpectation = expect("Invitation sent.")
    
    Inject.mock(ChatManagerInterface.self) {
      MockChatManager(inviteHandler: { (peerId, invitation) in
        invitationExpectation.fulfill()
      })
    }
    
    Inject.Store().dispatch(BrowserState.Invite.send(to: .mock(), Invitation(purpose: .joinRequest)))
    
    waitFor(invitationExpectation)
  }
  
  func testReceivedJoinRequest() {
    setUpDefaultMocks()
    let confirmationExpectation = expect("Confirmation sent.")
    
    Inject.mock(ChatManagerInterface.self) {
      MockChatManager(inviteHandler: { (peerId, invitation) in
        XCTAssert(
          invitation.purpose == .confirmation,
          "Expected a .confirmation response to a .joinRequest.")
        confirmationExpectation.fulfill()
      })
    }
    
    let invitation = Invitation(purpose: .joinRequest, profile: .mock())
    let joinRequest = BrowserState.Invite.received(invitation, { _, _ in }, .mock())
    Inject.Store().dispatch(joinRequest)
    
    waitFor(confirmationExpectation)
  }
  
  func testReceivedConfirmation() {
    setUpDefaultMocks()
    let acceptanceExpectation = expect("Confirmation accepted.")

    let hostProfile = Profile.mock()
    let invitation = Invitation(purpose: .confirmation, profile: hostProfile)
    
    let handler: InvitationHandler = { didAccept, session in
      XCTAssert(didAccept, "Expected to accept the join confirmation.")
      acceptanceExpectation.fulfill()
    }
    
    let confirmInvite = BrowserState.Invite.received(invitation, handler, .mock())
    Inject.Store().dispatch(confirmInvite)
    
    waitFor(acceptanceExpectation)
    
    guard let guestChat = Inject.Store().state.guestChat else {
      XCTFail("Expected a guestChat after accepting invitation.")
      return
    }
    
    XCTAssert(
      guestChat.host == hostProfile,
      "Expected guestChat to have matching peerId the inviter.")
  }
}
