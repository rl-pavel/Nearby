import Foundation

struct Message: Equatable, Codable {
  var date = Inject.Date()
  var sender: Profile = Inject.Preferences().userProfile
  var text: String  
}
