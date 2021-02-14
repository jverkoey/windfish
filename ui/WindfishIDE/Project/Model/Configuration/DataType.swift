import Foundation

import Windfish

final class DataType: NSObject {
  init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
    self.name = name
    self.representation = representation
    self.interpretation = interpretation
    self.mappings = mappings
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

  func toWindfish() -> Windfish.Project.DataType {
    return Windfish.Project.DataType(name: name, representation: representation, interpretation: interpretation, mappings: mappings.map {
      Windfish.Project.DataType.Mapping(name: $0.name, value: $0.value)
    })
  }
}
