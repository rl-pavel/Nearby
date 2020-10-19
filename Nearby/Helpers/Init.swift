import Foundation

func Init<Type>(_ object: Type, _ customize: (Type) -> Void) -> Type {
  customize(object)
  return object
}
