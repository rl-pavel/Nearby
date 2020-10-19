import Foundation

func Init<Type>(_ value: Type, _ customize: (Type) -> Void) -> Type {
  customize(value)
  return value
}
