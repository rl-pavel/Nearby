import MultipeerConnectivity

struct Message {
  var date = Date()
  var sender = ChatManager.shared.userPeer
  var text: String
}


// MARK: - Codable Implementation

extension Message: Codable {
  enum CodingKeys: String, CodingKey {
    case date
    case sender
    case text
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    date = try container.decode(Date.self, forKey: .date)
    text = try container.decode(String.self, forKey: .text)
    
    let peerData = try container.decode(Data.self, forKey: .sender)
    sender = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(peerData) as! MCPeerID
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(date, forKey: .date)
    try container.encode(text, forKey: .text)
    
    let peerData = try NSKeyedArchiver.archivedData(withRootObject: sender, requiringSecureCoding: false)
    try container.encode(peerData, forKey: .sender)
  }
}
