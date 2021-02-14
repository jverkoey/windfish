import Foundation

import Windfish

final class Script: NSObject {
  init(name: String, source: String) {
    self.storage = Windfish.Project.Script(name: name, source: source)
  }

  @objc dynamic var name: String {
    get { return storage.name }
    set { storage.name = newValue }
  }
  @objc dynamic var source: String {
    get { return storage.source }
    set { storage.source = newValue }
  }

  // Internal storage.
  let storage: Windfish.Project.Script
}
