import Foundation
import ReSwift
import MultipeerConnectivity

struct State: StateType {
  
  // MARK: - Properties
  
  var browserState = BrowserState()
  
  var hostChat = ChatState(host: ChatManager.shared.userPeer)
  var guestChat: ChatState?
  
  
  // MARK: - Reducer
  
  static func reduce(action: Action, state: State?) -> State {
    return State(
      browserState: BrowserState.reduce(action: action, state: state?.browserState),
      hostChat: ChatState.hostChatReduce(action: action, state: state?.hostChat),
      guestChat: ChatState.guestChatReduce(action: action, state: state?.guestChat))
  }
}


