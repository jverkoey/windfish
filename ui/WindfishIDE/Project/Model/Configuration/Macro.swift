import Foundation

final class Macro: NSObject {
  internal init(name: String, source: String) {
    self.name = name
    self.source = source
  }

  @objc dynamic var name: String
  @objc dynamic var source: String
}
