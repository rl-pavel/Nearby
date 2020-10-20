import Foundation

struct Invitation: Codable {
  enum Purpose: String, Codable {
    case joinRequest, confirmation
  }
  
  var purpose: Purpose
  var messageHistory: [Message]?
  var profile = Preferences.shared.userProfile
}
