import Foundation
import ReSwift

let Store = ReSwift.Store(
  reducer: reduce,
  state: State(),
  middleware: [
    Middleware.create(BrowserState.middleware),
    Middleware.create(ChatState.middleware)
  ]
)

