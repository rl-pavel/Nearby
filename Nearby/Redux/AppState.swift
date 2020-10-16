import Foundation
import ReSwift
import MultipeerConnectivity

// MARK: - State

struct State: StateType {
  var browserState = BrowserState()
  var chatState = ChatState()
}

func reduce(action: Action, state: State?) -> State {
  return State(
    browserState: BrowserState.reduce(action: action, state: state?.browserState),
    chatState: ChatState.reduce(action: action, state: state?.chatState))
}
