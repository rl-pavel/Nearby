import MultipeerConnectivity

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userProfile",defaultValue: .defaultProfile)
  var userProfile: Profile
  
  let userDefaults = UserDefaults()
  
  
  // MARK: - Inits
  
  private init() { }
}
