import Foundation

final class DataType: NSObject {
  init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
    self.name = name
    self.representation = representation
    self.interpretation = interpretation
    self.mappings = mappings
  }

  struct Interpretation {
    static let any = "Any"
    static let enumerated = "Enumerated"
    static let bitmask = "Bitmask"
  }
  struct Representation {
    static let decimal = "Decimal"
    static let hexadecimal = "Hex"
    static let binary = "Binary"
  }

  final class Mapping: NSObject, Codable {
    internal init(name: String, value: UInt8) {
      self.name = name
      self.value = value
    }

    @objc dynamic var name: String
    @objc dynamic var value: UInt8
  }

  @objc dynamic var name: String
  @objc dynamic var representation: String
  @objc dynamic var interpretation: String
  @objc dynamic var mappings: [Mapping]
}
