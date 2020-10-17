import Foundation

extension Encodable {
  func encoded(
    using dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601,
    keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) throws -> Data {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = dateEncodingStrategy
    jsonEncoder.keyEncodingStrategy = keyEncodingStrategy
    
    return try jsonEncoder.encode(self)
  }
}

extension Decodable {
  static func decode(
    from data: Data,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> Self {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
    jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
    
    return try jsonDecoder.decode(Self.self, from: data)
  }
}
