import MultipeerConnectivity

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @NSCodingPreference("userPeer", defaultValue: .init(displayName: UIDevice.current.name))
  var userPeer: MCPeerID
  
  let userDefaults = UserDefaults()
  
  
  // MARK: - Inits
  
  private init() {
    
  }
}
