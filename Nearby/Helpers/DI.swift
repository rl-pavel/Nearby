import Foundation

// Source: https://noahgilmore.com/blog/swift-dependency-injection/
enum DI {
  typealias Instantiator<Dependency> = () -> Dependency
  
  // MARK: - Properties
  
  private static var isTesting = ProcessInfo.processInfo.arguments.contains("TESTING")
  private static var instantiators: [String: Any] = [:]
  private static var mockInstantiators: [String: Any] = [:]
  
  
  // MARK: - Functions
  
  static func bind<Dependency>(
    _ dependencyType: Dependency.Type = Dependency.self,
    instantiator: @escaping Instantiator<Dependency>) -> Instantiator<Dependency> {
    let descriptor = String(describing: dependencyType)
    instantiators[descriptor] = instantiator
    return instance
  }
  
  static func mock<Dependency>(
    _ dependencyType: Dependency.Type,
    instantiator: @escaping Instantiator<Dependency>) {
    let descriptor = String(describing: dependencyType)
    mockInstantiators[descriptor] = instantiator
  }
  
  static func unmock() {
    mockInstantiators.removeAll()
  }
  
  
  // MARK: - Helper Functions
  
  private static func instance<Dependency>() -> Dependency {
    let descriptor = String(describing: Dependency.self)
    
    if isTesting {
      if let instantiator = mockInstantiators[descriptor] as? Instantiator<Dependency> {
        return instantiator()
        
      } else {
        fatalError("Type \(descriptor) not mocked for tests.")
      }
    }
    
    let instantiator = instantiators[descriptor] as! Instantiator<Dependency>
    return instantiator()
  }
}
