import MultipeerConnectivity

struct Profile {
  
  // MARK: - Properties
  
  var peerId: MCPeerID
  var name: String
  var avatar: UIImage?
  
  static let defaultProfile: Profile = {
    return Profile(peerId: .devicePeerId, userName: UIDevice.current.name)
  }()
  
  
  // MARK: - Inits
  
  init(
    peerId: MCPeerID = Preferences.shared.userProfile.peerId,
    userName: String,
    avatar: UIImage? = nil) {
    self.peerId = peerId
    self.name = userName
    self.avatar = avatar
  }
}


// MARK: - Equatable Implementation

extension Profile: Equatable {
  static func == (lhs: Profile, rhs: Profile) -> Bool {
    return lhs.peerId.id == rhs.peerId.id
  }
}


// MARK: - Codable Implementation

extension Profile: Codable {
  enum CodingKeys: String, CodingKey {
    case peerId
    case userName
    case avatar
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let peerData = try container.decode(Data.self, forKey: .peerId)
    peerId = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(peerData) as! MCPeerID
    
    name = try container.decode(String.self, forKey: .userName)
    
    if let imageData = try container.decodeIfPresent(Data.self, forKey: .avatar) {
      avatar = UIImage(data: imageData)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(name, forKey: .userName)
    
    let peerData = try NSKeyedArchiver.archivedData(withRootObject: peerId, requiringSecureCoding: false)
    try container.encode(peerData, forKey: .peerId)
    
    try container.encodeIfPresent(avatar?.pngData(), forKey: .avatar)
  }
}


// MARK: - MCPeerID Helpers

extension MCPeerID {
  var id: String {
    return displayName
  }
  
  static var devicePeerId: MCPeerID {
    let identifier = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
    return MCPeerID(displayName: identifier)
  }
}

