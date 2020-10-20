import Foundation

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

extension Optional where Wrapped: Comparable {
  /// Unwraps both sides, returning `false` if either is `nil`, then performs the comparison check.
  static func >? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs > rhs
  }
  
  /// Unwraps both sides, returning `false` if either is `nil`, then performs the comparison check.
  static func >=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs >= rhs
  }
  
  /// Unwraps both sides, returning `false` if either is `nil`, then performs the comparison check.
  static func <? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs < rhs
  }
  
  /// Unwraps both sides, returning `false` if either is `nil`, then performs the comparison check.
  static func <=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs <= rhs
  }
}

extension Optional where Wrapped: Equatable {
  /// Unwraps both sides, returning `false` if either is `nil`, then performs the equation check.
  static func !=? (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }
    
    return lhs != rhs
  }
}
