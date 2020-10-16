import Foundation
import MultipeerConnectivity
import ReSwift

struct Message {
  let sender: String
  let text: String
}

struct ChatState: StateType {
  var messages = [Message]()
  var session: MCSession?
}

extension ChatState {
  
  // MARK: - Actions
  
  struct AddMessage: Action {
    let message: Message
    
    init(_ message: Message) {
      self.message = message
    }
  }
  
  struct SetSession: Action {
    let session: MCSession?
  }
  
  
  // MARK: - Middleware
  
  static func middleware(action: Action, context: Middleware.Context<State>) -> Action? {
    let myPeerId = ChatManager.shared.myPeerId
    
    switch action {
      case let action as AddMessage where action.message.sender == myPeerId.displayName:
        guard let messageData = action.message.text.data(using: .utf8),
              let session = context.state?.chatState.session else {
          return nil
        }
        
        do {
          try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
          
        } catch let error {
          print("Failed to send message with error: \(error)")
          return nil
        }
        
      default:
        break
    }
    
    return action
  }
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: Self?) -> Self {
    var state = state ?? .init()
    
    switch action {
      case let action as AddMessage:
        state.messages.append(action.message)
        
      case let action as SetSession:
        state.session = action.session
        
      default:
        break
    }
    
    return state
  }

}
