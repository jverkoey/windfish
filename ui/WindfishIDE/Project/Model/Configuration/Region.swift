import Foundation

import LR35902
import Tracing
import Windfish

final class Region: NSObject {
  typealias Storage = Windfish.Project.Region

  init(storage: Storage) {
    self.storage = storage
  }
  init(regionType: String, name: String, bank: Cartridge.Bank, address: LR35902.Address, length: LR35902.Address) {
    self.storage = Storage(regionType: regionType, name: name, bank: bank, address: address, length: length)
  }

  @objc dynamic var regionType: String {
    get { return storage.regionType }
    set {
      storage.regionType = newValue

      if newValue == Storage.Kind.label || newValue == Storage.Kind.function {
        length = 0
      }
    }
  }
  @objc dynamic var name: String {
    get { return storage.name }
    set { storage.name = newValue }
  }
  @objc dynamic var bank: Cartridge.Bank {
    get { return storage.bank }
    set { storage.bank = newValue }
  }
  @objc dynamic var address: LR35902.Address {
    get { return storage.address }
    set { storage.address = newValue }
  }
  @objc dynamic var length: LR35902.Address {
    get { return storage.length }
    set { storage.length = newValue }
  }

  // Internal storage.
  let storage: Storage
}
