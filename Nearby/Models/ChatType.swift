import Foundation

enum ChatType: String, Codable {
  /// Current user is the host of the chat.
  case host
  
  /// Current user is a guest in the chat.
  case guest
}
