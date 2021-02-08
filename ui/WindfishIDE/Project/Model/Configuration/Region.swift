import Foundation

import LR35902
import Tracing
import Windfish

final class Region: NSObject {
  struct Kind {
    static let region = "Region"
    static let label = "Label"
    static let function = "Function"
    static let string = "String"
    static let data = "Data"
    static let image1bpp = "Image (1bpp)"
    static let image2bpp = "Image (2bpp)"
  }
  @objc dynamic var regionType: String {
    didSet {
      if regionType == Kind.label || regionType == Kind.function {
        length = 0
      }
    }
  }
  @objc dynamic var name: String
  @objc dynamic var bank: Cartridge.Bank
  @objc dynamic var address: LR35902.Address
  @objc dynamic var length: LR35902.Address

  init(regionType: String, name: String, bank: Cartridge.Bank, address: LR35902.Address, length: LR35902.Address) {
    self.regionType = regionType
    self.name = name
    self.bank = bank
    self.address = address
    self.length = length
  }
}
