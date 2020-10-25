@testable import Nearby
import MultipeerConnectivity
import XCTest

class ChatStateTests: XCTestCase {
  func testSendMessageInHost() {
    setUpDefaultMocks()
    
    let messageMock = Message.mock()
    testSendMessage(messageMock, in: .host)
    validateMessageInHost(messageMock)  }
  
  func testSendMessageInGuest() {
    setUpDefaultMocks()
    
    let messageMock = Message.mock()
    testSendMessage(messageMock, in: .guest)
    validateMessageInGuest(messageMock)
  }
  
  
  func testMessageReceivedInHost() {
    setUpDefaultMocks()
    
    let messageMock = Message.mock()
    Inject.Store().dispatch(ChatState.ReceivedMessage(message: messageMock, chatType: .host))
    
    validateMessageInHost(messageMock)
  }
  
  func testMessageReceivedInGuest() {
    setUpDefaultMocks()
    
    let guestChat = ChatState(host: .mock(), type: .guest)
    Inject.Store().dispatch(AppState.SetGuestChat(chat: guestChat))
    
    let messageMock = Message.mock()
    Inject.Store().dispatch(ChatState.ReceivedMessage(message: messageMock, chatType: .guest))
    
    validateMessageInGuest(messageMock)
  }
}


// MARK: - Helper Functions

private extension ChatStateTests {
  func testSendMessage(_ message: Message, in chatType: ChatType) {
    let messageSentExpectation = expect("Message sent.")
      
    Inject.mock(ChatManagerInterface.self) {
      MockChatManager(sendMessageHandler: { message, resultChatType in
        XCTAssert(
          resultChatType == chatType,
          "Expected the message to be sent to host session.")
        messageSentExpectation.fulfill()
      })
    }
    
    let chat = ChatState(host: .mock(), type: chatType)
    
    Inject.Store().dispatch(AppState.SetGuestChat(chat: chat))
    Inject.Store().dispatch(ChatState.SendMessage(message, in: chat))
    
    waitFor(messageSentExpectation)
  }
  
  func validateMessageInHost(_ message: Message) {
    XCTAssert(
      Inject.Store().state.guestChat == nil,
      "Expected message to be added to host chat")
    XCTAssert(
      Inject.Store().state.hostChat.messages.contains(message),
      "Expected message to be added to host chat")
  }
  
  func validateMessageInGuest(_ message: Message) {
    XCTAssert(
      Inject.Store().state.hostChat.messages.isEmpty,
      "Expected message to be added to guest chat")
    XCTAssert(
      Inject.Store().state.guestChat?.messages.contains(message) == true,
      "Expected message to be added to guest chat")
  }
}
