import Foundation

import Windfish

final class Macro: NSObject {
  internal init(name: String, source: String) {
    self.storage = Windfish.Project.Macro(name: name, source: source)
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
  private let storage: Windfish.Project.Macro
}
