@testable import Nearby

class MockPreferences: PreferencesInterface {
  @Preference("userProfile", defaultValue: .mock())
  var userProfile: Profile
}
