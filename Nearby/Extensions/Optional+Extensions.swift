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


extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    return self?.isEmpty ?? true
  }
}


// MARK: - Optional Comparable Operators

infix operator >?: NilCoalescingPrecedence
infix operator >=?: NilCoalescingPrecedence
infix operator <?: NilCoalescingPrecedence
infix operator <=?: NilCoalescingPrecedence
infix operator !=?: NilCoalescingPrecedence

// All the operators here will return false if either of the sides is nil.
// Otherwise they'll return the comparison result of the unwrapped values.
extension Optional where Wrapped: Comparable {
  static func >? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs > rhs
  }
  static func >=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs >= rhs
  }
  static func <? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs < rhs
  }
  static func <=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs <= rhs
  }
}

extension Optional where Wrapped: Equatable {
  static func !=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs != rhs
  }
}