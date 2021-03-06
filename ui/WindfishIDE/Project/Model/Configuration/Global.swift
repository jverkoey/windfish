import Foundation

import LR35902
import Windfish

final class Global: NSObject {
  typealias Storage = Windfish.Project.Global

  init(storage: Storage) {
    self.storage = storage
  }
  init(name: String, address: LR35902.Address, dataType: String) {
    self.storage = Storage(name: name, address: address, dataType: dataType)
  }

  @objc dynamic var name: String {
    get { return storage.name }
    set { storage.name = newValue }
  }
  @objc dynamic var address: LR35902.Address {
    get { return storage.address }
    set { storage.address = newValue }
  }
  @objc dynamic var dataType: String {
    get { return storage.dataType }
    set { storage.dataType = newValue }
  }

  // Internal storage.
  let storage: Storage
}
