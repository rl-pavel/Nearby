import MultipeerConnectivity

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userProfile",defaultValue: .defaultProfile)
  var userProfile: Profile
  
  @Preference("chatHistory")
  var chatHistory: ChatState?
  
  let userDefaults = UserDefaults()
  
  
  // MARK: - Inits
  
  private init() { }
}
