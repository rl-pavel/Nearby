import UIKit

class Preferences {
  
  // MARK: - Properties
  
  static let shared = Preferences()
  
  @Preference("userName", defaultValue: UIDevice.current.name)
  var userName: String
  
  fileprivate let _userDefaults = UserDefaults()
  
  
  // MARK: - Inits
  
  private init() { }
}


// MARK: - Preference Property Wrapper

@propertyWrapper
struct Preference<Value: Codable> {
  
  // MARK: - Properties
  
  let key: String
  let defaultValue: Value
  
  var wrappedValue: Value {
    get {
      let storedValue = Preferences.shared._userDefaults.object(forKey: key)
      
      // Try to get the stored data for decoding, or fall back to the raw representation.
      guard let data = storedValue as? Data else {
        return storedValue as? Value ?? defaultValue
      }
      
      let decodedValue = try? Value.decode(from: data)
      return decodedValue ?? defaultValue
    }
    set {
      let userDefaults = Preferences.shared._userDefaults
      
      // Clear out the object if the new value is an Optional and nil.
      if let optionalValue = newValue as? AnyOptional, optionalValue.isNil {
        userDefaults.removeObject(forKey: key)
        return
      }
      
      let encodedValue = try? newValue.encoded()
      userDefaults.set(encodedValue ?? newValue, forKey: key)
    }
  }
  
  
  // MARK: - Inits
  
  init(_ key: String, defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  init(_ key: String) where Value: OptionalType {
    self.key = key
    self.defaultValue = nil
  }
}
