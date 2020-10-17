import Foundation

@propertyWrapper
struct Preference<Value: Codable> {
  
  // MARK: - Properties
  
  let key: String
  let defaultValue: Value
  
  var wrappedValue: Value {
    get {
      let storedValue = Preferences.shared.userDefaults.object(forKey: key)
      
      // Try to get the stored data for decoding, or fall back to the raw representation.
      guard let data = storedValue as? Data else {
        return storedValue as? Value ?? defaultValue
      }
      
      return (try? JSONDecoder().decode(Value.self, from: data)) ?? defaultValue
    }
    set {
      let userDefaults = Preferences.shared.userDefaults
      
      // Clear out the object if the new value is an Optional and nil.
      if let optionalValue = newValue as? AnyOptional, optionalValue.isNil {
        userDefaults.removeObject(forKey: key)
        return
      }
      
      let encodedValue = try? JSONEncoder().encode(newValue)
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
