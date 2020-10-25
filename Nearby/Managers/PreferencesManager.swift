import MultipeerConnectivity

// MARK: - Preferences Interface

protocol PreferencesInterface: class {
  var userProfile: Profile { get set }
}

extension Inject {
  static let Preferences = bind(PreferencesInterface.self) { Nearby.Preferences.shared }
}


// MARK: - Preferences Implementation

private class Preferences: PreferencesInterface {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userProfile",defaultValue: .defaultProfile)
  var userProfile: Profile
  
  // MARK: - Inits
  
  private init() { }
}
