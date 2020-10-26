@testable import Nearby
import MultipeerConnectivity
import ReSwift
import XCTest

extension XCTestCase {
  func setUpDefaultMocks(for testName: String = #function, in fileName: String = #fileID) {
    Inject.isTesting = true
    
    let suitName = "com.op.\(fileName).\(testName)"
    let userDefaults = UserDefaults(suiteName: suitName)!
    userDefaults.removePersistentDomain(forName: suitName)
    
    Inject.mock(Date.self) { Date() }
    Inject.mock(UserDefaults.self) { userDefaults }
    Inject.mock(PreferencesInterface.self) { MockPreferences() }
    Inject.mock(ChatManagerInterface.self) { MockChatManager() }
    
    let mockStore = Store(
      reducer: AppState.reduce,
      state: AppState(),
      middleware: [
        Middleware.create(AppState.middleware),
        Middleware.create(BrowserState.middleware),
        Middleware.create(ChatState.middleware)
      ])
    
    Inject.mock(ReSwift.Store.self) { mockStore }
    
    addTeardownBlock {
      Inject.unmock()
      Inject.isTesting = false
    }
  }
}

extension MCPeerID {
  static func mock(displayName: String = UUID().uuidString) -> MCPeerID {
    return MCPeerID(displayName: displayName)
  }
}

extension MCSession {
  static func mock(peer: MCPeerID = .mock()) -> MCSession {
    return MCSession(peer: peer)
  }
}


extension Profile {
  static func mock(
    peerId: MCPeerID = .mock(),
    userName: String = UUID().uuidString,
    avatar: UIImage? = nil) -> Profile {
    return Profile(peerId: peerId, userName: userName, avatar: avatar)
  }
}

extension Message {
  static func mock(profile: Profile = .mock(), text: String = UUID().uuidString) -> Message {
    return Message(
      date: Inject.Date(),
      sender: profile,
      text: text)
  }
}
