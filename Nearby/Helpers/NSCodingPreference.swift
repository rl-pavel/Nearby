import Foundation

@propertyWrapper
struct NSCodingPreference<Value: NSSecureCoding> {
  
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
      
      let decodedValue = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Value
      return decodedValue ?? defaultValue
    }
    set {
      let userDefaults = Preferences.shared.userDefaults
      let encodedValue = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
      
      userDefaults.set(encodedValue ?? newValue, forKey: key)
    }
  }
  
  
  // MARK: - Inits
  
  init(_ key: String, defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }
}
