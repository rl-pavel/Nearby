import Foundation

struct Message: Equatable, Codable {
  var date = Date()
  var sender = Preferences.shared.userProfile
  var text: String  
}
