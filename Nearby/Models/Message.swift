import Foundation

struct Message: Equatable, Codable {
  var date = Date()
  var sender: Profile = Preferences.shared.userProfile
  var text: String  
}
