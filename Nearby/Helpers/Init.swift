import Foundation

func Init<T: NSObject>(_ customize: (T) -> Void) -> T {
  let object = T.init()
  customize(object)
  return object
}
