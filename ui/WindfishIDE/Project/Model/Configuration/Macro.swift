import Foundation

import Windfish

final class Macro: NSObject {
  typealias Storage = Windfish.Project.Macro

  init(storage: Storage) {
    self.storage = storage
  }
  init(name: String, source: String) {
    self.storage = Storage(name: name, source: source)
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
  let storage: Storage
}
