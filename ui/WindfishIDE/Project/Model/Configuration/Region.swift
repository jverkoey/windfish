import Foundation

import LR35902
import Tracing
import Windfish

final class Region: NSObject {
  init(regionType: String, name: String, bank: Cartridge.Bank, address: LR35902.Address, length: LR35902.Address) {
    self.regionType = regionType
    self.name = name
    self.bank = bank
    self.address = address
    self.length = length
  }

  @objc dynamic var regionType: String {
    didSet {
      if regionType == Windfish.Project.Region.Kind.label || regionType == Windfish.Project.Region.Kind.function {
        length = 0
      }
    }
  }
  @objc dynamic var name: String
  @objc dynamic var bank: Cartridge.Bank
  @objc dynamic var address: LR35902.Address
  @objc dynamic var length: LR35902.Address

  func toWindfish() -> Windfish.Project.Region {
    return Windfish.Project.Region(regionType: regionType, name: name, bank: bank, address: address, length: length)
  }
}
