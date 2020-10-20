import Foundation

struct Message: Equatable, Codable {
  var date = Date()
  var sender = Profile()
  var text: String
}
