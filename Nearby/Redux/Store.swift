import Foundation
import ReSwift

var Store = ReSwift.Store(
  reducer: State.reduce,
  state: State(),
  middleware: [
    Middleware.create(BrowserState.middleware),
    Middleware.create(ChatState.middleware)
  ]
)
