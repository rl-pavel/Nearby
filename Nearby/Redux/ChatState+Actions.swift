import ReSwift

extension ChatState {
  struct SetGuestChat: Action {
    let chat: ChatState?
  }
  
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
    let sessionType: ChatClient.SessionType
  }
}