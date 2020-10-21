import Foundation
import MultipeerConnectivity
import ReSwift

struct ChatState: StateType, Codable {
  
  // MARK: - Properties
  
  let host: Profile
  var messages = [Message]()
}


// MARK: - Equatable Implementation

extension ChatState: Equatable {
  static func == (lhs: ChatState, rhs: ChatState) -> Bool {
    return lhs.host == rhs.host
  }
}
