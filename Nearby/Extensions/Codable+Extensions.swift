import Foundation

extension Encodable {
  func encoded(
    using dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
    keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = dateEncodingStrategy
    jsonEncoder.keyEncodingStrategy = keyEncodingStrategy
    
    return try jsonEncoder.encode(self)
  }
}

extension Decodable {
  static func decode(
    from data: Data,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> Self {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
    jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
    
    return try jsonDecoder.decode(Self.self, from: data)
  }
}
