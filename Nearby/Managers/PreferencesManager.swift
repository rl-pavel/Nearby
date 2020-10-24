import MultipeerConnectivity

// MARK: - Preferences Interface

protocol PreferencesType: class {
  var userProfile: Profile { get set }
  var chatHistory: ChatState? { get set }
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
  
  // TODO: - Store chat history in a database.
  @Preference("chatHistory")
  var chatHistory: ChatState?

  
  // MARK: - Inits
  
  private init() { }
}
