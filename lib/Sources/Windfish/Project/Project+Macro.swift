import Foundation

extension Project {
  final class Macro: NSObject {
    init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    var name: String
    var source: String
  }
}
