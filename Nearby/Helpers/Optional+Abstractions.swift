import Foundation

protocol OptionalType: ExpressibleByNilLiteral {
  associatedtype Wrapped
  var optional: Wrapped? { get }
}
extension Optional: OptionalType {
  var optional: Wrapped? { return self }
}

protocol AnyOptional {
  var isNil: Bool { get }
}
extension Optional: AnyOptional {
  var isNil: Bool {
    return self == nil
  }
}
