import Foundation

import Windfish

final class Script: NSObject {
  init(name: String, source: String) {
    self.name = name
    self.source = source
  }

  @objc dynamic var name: String
  @objc dynamic var source: String

  func toWindfish() -> Windfish.Project.Script {
    return Windfish.Project.Script(name: name, source: source)
  }
}
