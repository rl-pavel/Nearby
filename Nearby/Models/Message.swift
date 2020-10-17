import Foundation

struct Message: Codable {
  var date = Date()
  var sender = ChatManager.shared.userPeer.displayName
  var text: String
}
