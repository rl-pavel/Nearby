import MultipeerConnectivity

// MARK: - Preferences Interface

protocol PreferencesType: class {
  var userProfile: Profile { get set }
}

extension DI {
  static let Preferences = bind(PreferencesType.self) { Nearby.Preferences.shared }
}


// MARK: - Preferences Implementation

private class Preferences: PreferencesType {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userProfile",defaultValue: .defaultProfile)
  var userProfile: Profile
  
  // MARK: - Inits
  
  private init() { }
}
