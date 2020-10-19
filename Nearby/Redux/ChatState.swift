import Foundation
import MultipeerConnectivity
import ReSwift

struct ChatState: StateType {
  
  // MARK: - Properties
  
  // TODO: - Create Profile model. Add avatar image in Base64 String representation:
  // https://www.mysamplecode.com/2019/04/ios-swift-convert-image-base64.html
  let host: MCPeerID
  
  var messages = [Message]()
}


// MARK: - Equatable Implementation

extension ChatState: Equatable {
  static func == (lhs: ChatState, rhs: ChatState) -> Bool {
    return lhs.host == rhs.host
  }
}
