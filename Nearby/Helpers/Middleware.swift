import ReSwift

typealias MiddlewareAction<State: StateType> = (Action, Middleware.Context<State>) -> Action?
typealias StateContext = Middleware.Context<State>

struct Middleware {
  struct Context<State: StateType> {
    
    /// Closure that can be used to emit additional actions, that go through the middleware.
    /// NOTE: Do not dispatch the current action, that will lead to an infinite loop. Use `next` instead.
    let dispatch: DispatchFunction
    let getState: () -> State?
    
    /// Closure that is returned from the middleware, which forwards the action to the reducer.
    /// In case of an async operation, return `nil` and use `dispatch` within the callback for other actions.
    let next: DispatchFunction
    
    var state: State? {
      return getState()
    }
  }
  
  /// Creates a middleware function using SimpleMiddleware to create a ReSwift Middleware function.
  static func create<State: StateType>(_ middleware: @escaping MiddlewareAction<State>) -> ReSwift.Middleware<State> {
    return { dispatch, getState in
      return { next in
        return { action in
          
          let context = Context(dispatch: dispatch, getState: getState, next: next)
          if let newAction = middleware(action, context) {
            next(newAction)
          }
        }
      }
    }
  }
}
