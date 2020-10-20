import MultipeerConnectivity

struct Profile: Equatable {
  let peerId: MCPeerID
  var avatar: UIImage?
  
  init(peerId: MCPeerID = Preferences.shared.userProfile.peerId, avatar: UIImage? = nil) {
    self.peerId = peerId
    self.avatar = avatar
  }
}


// MARK: - Codable Implementation

extension Profile: Codable {
  enum CodingKeys: String, CodingKey {
    case peerId
    case avatar
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    if let imageData = try container.decodeIfPresent(Data.self, forKey: .avatar) {
      avatar = UIImage(data: imageData)
    }
    
    let peerData = try container.decode(Data.self, forKey: .peerId)
    peerId = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(peerData) as! MCPeerID
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    if let imageData = avatar?.pngData() {
      try container.encode(imageData, forKey: .avatar)
    }
    
    let peerData = try NSKeyedArchiver.archivedData(withRootObject: peerId, requiringSecureCoding: false)
    try container.encode(peerData, forKey: .peerId)
  }
}
