import MultipeerConnectivity
import ReSwift

typealias VoidClosure = () -> Void

typealias InvitationHandler = (Bool, MCSession?) -> Void

typealias MiddlewareContext = Middleware.Context<AppState>

