import ReSwift

// Slightly modified from source: http://bit.ly/2DCMmyX
struct Middleware {
  typealias Action<State: StateType> = (ReSwift.Action, Middleware.Context<State>) -> ReSwift.Action?
  
  struct Context<State: StateType> {
    
    /// Closure that can be used to emit additional actions.
    /// NOTE: Do not dispatch the current action, that will lead to an infinite loop. Use `next` instead.
    let dispatch: DispatchFunction
    
    /// Closure that is returned from the middleware, which forwards the action to the reducer.
    /// In case of an async operation, return `nil` and use `dispatch` within the callback for other actions.
    let next: DispatchFunction
    
    var state: State? { getState() }
    
    fileprivate let getState: () -> State?
  }
  
  
  /// Creates a middleware using a Context object to abstract the nested closured.
  static func create<State: StateType>(_ middleware: @escaping Action<State>) -> ReSwift.Middleware<State> {
    return { dispatch, getState in
      return { next in
        return { action in
          
          let context = Context(dispatch: dispatch, next: next, getState: getState)
          if let newAction = middleware(action, context) {
            next(newAction)
          }
        }
      }
    }
  }
}
