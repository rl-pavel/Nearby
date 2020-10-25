import Foundation
import MultipeerConnectivity
import ReSwift

struct ChatState: StateType, Codable {
  
  // MARK: - Properties
  
  var host: Profile
  var type: ChatType 
  var messages = [Message]()
}


// MARK: - Actions

extension ChatState {
  struct SendMessage: Action {
    let message: Message
    let chat: ChatState
    
    init(_ message: Message, in chat: ChatState) {
      self.message = message
      self.chat = chat
    }
  }
  
  struct ReceivedMessage: Action {
    let message: Message
    let chatType: ChatType
  }
}


// MARK: - Equatable Implementation

extension ChatState: Equatable {
  static func == (lhs: ChatState, rhs: ChatState) -> Bool {
    return lhs.host == rhs.host
  }
}
