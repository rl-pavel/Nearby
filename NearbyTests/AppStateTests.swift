@testable import Nearby
import XCTest
import MultipeerConnectivity

class AppStateTests: XCTestCase {
  func testProfileUpdate() {
    setUpDefaultMocks()
    
    let discoveryUpdateExpectation = expect("Discovery updated.")
    
    Inject.mock(ChatManagerInterface.self) {
      MockChatManager(setUpHandler: {
        discoveryUpdateExpectation.fulfill()
      })
    }
    
    let newPeerId = MCPeerID.mock()
    let userName = UUID().uuidString
    Inject.Store().dispatch(AppState.UpdateProfile(name: userName, peerId: newPeerId))
    
    waitFor(discoveryUpdateExpectation)
    
    XCTAssert(
      Inject.Preferences().userProfile.name == userName,
      "Preferences.userProfile.name not updated.")
    XCTAssert(
      Inject.Preferences().userProfile.peerId == newPeerId,
      "`Preferences.userProfile.peerId not updated.")
    
    XCTAssert(
      Inject.Store().state.hostChat.host.name == userName,
      "AppState.hostChat.host.name not updated.")
    XCTAssert(
      Inject.Store().state.hostChat.host.peerId == newPeerId,
      "AppState.hostChat.host.peerId not updated.")
  }
  
  func testSetUnsetGuestChat() {
    setUpDefaultMocks()
    
    let guestChat = ChatState(host: .mock(), type: .guest)
    testSetGuestChat(guestChat)
    
    let disconnectExpectation = expect("Disconnected from host.")
    
    Inject.mock(ChatManagerInterface.self) {
      MockChatManager(disconnectHandler: {
        disconnectExpectation.fulfill()
      })
    }
    
    Inject.Store().dispatch(AppState.SetGuestChat(chat: nil))
    waitFor(disconnectExpectation)
    
    XCTAssert(
      Inject.Store().state.guestChat == nil,
      "Expected guestChat to be removed from state.")
  }
  
  func testSetInvalidGuestChat() {
    setUpDefaultMocks()
    
    let hostChat = ChatState(host: .mock(), type: .host)
    Inject.Store().dispatch(AppState.SetGuestChat(chat: hostChat))
    
    XCTAssert(
      Inject.Store().state.guestChat == nil,
      "Expected hostChat to NOT be removed on state.")
  }
  
  func testLostConnectionToHost() {
    setUpDefaultMocks()
    
    let hostProfile = Profile.mock()
    let guestChat = ChatState(host: hostProfile, type: .guest)
    testSetGuestChat(guestChat)
    
    Inject.Store().dispatch(BrowserState.Connection.lost(hostProfile.peerId))
    
    XCTAssert(
      Inject.Store().state.guestChat == nil,
      "Expected guestChat to be removed from state after the host disconnected.")
  }
  
  func testSetGuestChat(_ guestChat: ChatState) {
    Inject.Store().dispatch(AppState.SetGuestChat(chat: guestChat))
    
    XCTAssert(
      Inject.Store().state.guestChat == guestChat,
      "Expected guestChat to be set on state.")
  }
}
