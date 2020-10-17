import Foundation
import MultipeerConnectivity
import ReSwift

struct ChatState: StateType {
  
  // MARK: - Properties
  
  // TODO: - Create Profile model. Add avatar image in Base64 String representation:
  // https://www.mysamplecode.com/2019/04/ios-swift-convert-image-base64.html
  let host: MCPeerID
  
  var messages = [Message]()
  var isPending = false
  
  
  // MARK: - Actions
  
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
    let sessionType: SessionClient.SessionType
  }
  
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: StateContext) -> Action? {
    let chatManager = ChatManager.shared
    let state = context.state
    
    switch action {
      case let action as SendMessage:
        guard let chat = state?.guestChat ?? state?.hostChat else {
          fatalError("Message sent without a chat? 🤔")
        }
        
        chatManager.sendMessage(action.message, to: chat.host)
        
      default: break
    }
    
    return action
  }
  
  
  // MARK: - Reducer
  
  static func hostChatReduce(action: Action, state: Self?) -> Self {
    var state = state ?? .init(host: ChatManager.shared.userPeer)
    
    switch action {
      case let action as ReceivedMessage where action.sessionType == .host:
        state.messages.append(action.message)
        
      case let action as SendMessage where action.chat.host == state.host:
        state.messages.append(action.message)
        
      default: break
    }
    
    return state
  }
  
  static func guestChatReduce(action: Action, state: Self?) -> Self? {
    var state = state
    
    switch action {
      case let action as SetGuestChat:
        return action.chat
        
      case let action as ReceivedMessage where action.sessionType == .guest:
        state?.messages.append(action.message)
        
      case let action as SendMessage where action.chat.host == state?.host:
        state?.messages.append(action.message)
        
      default: break
    }
    
    return state
  }
}


extension ChatState: Equatable {
  static func == (lhs: ChatState, rhs: ChatState) -> Bool {
    return lhs.host == rhs.host
  }
}
