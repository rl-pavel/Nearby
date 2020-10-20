import MultipeerConnectivity

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userProfile", defaultValue: .init(peerId: MCPeerID(displayName: UIDevice.current.name)))
  var userProfile: Profile
  
  let userDefaults = UserDefaults()
  
  
  // MARK: - Inits
  
  private init() {
    
  }
}
