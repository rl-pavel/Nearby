import ReSwift

extension Inject {
  static let Store = bind(ReSwift.Store.self) { Nearby.Store }
}

fileprivate var Store = ReSwift.Store(
  reducer: AppState.reduce,
  state: AppState(),
  middleware: [
    Middleware.create(AppState.middleware),
    Middleware.create(BrowserState.middleware),
    Middleware.create(ChatState.middleware)
  ]
)
