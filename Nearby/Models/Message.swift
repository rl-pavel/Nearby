import Foundation

struct Message: Equatable, Codable {
  var date = DI.Date()
  var sender: Profile = DI.Preferences().userProfile
  var text: String  
}
