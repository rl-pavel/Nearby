import UIKit

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userName", defaultValue: UIDevice.current.name)
  var userName: String
  
  let userDefaults = UserDefaults()
  
  // MARK: - Inits
  
  private init() { }
}
