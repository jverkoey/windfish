import Foundation

extension Project {
  final class Script: NSObject {
    init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    var name: String
    var source: String
  }
}
