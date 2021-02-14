import Foundation

import Windfish

final class Macro: NSObject {
  internal init(name: String, source: String) {
    self.name = name
    self.source = source
  }

  @objc dynamic var name: String
  @objc dynamic var source: String

  func toWindfish() -> Windfish.Project.Macro {
    return Windfish.Project.Macro(name: name, source: source)
  }
}
