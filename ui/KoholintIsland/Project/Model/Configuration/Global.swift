import Foundation

import Windfish

final class Global: NSObject, Codable {
  internal init(name: String, address: LR35902.Address, dataType: String) {
    self.name = name
    self.address = address
    self.dataType = dataType
  }

  @objc dynamic var name: String
  @objc dynamic var address: LR35902.Address
  @objc dynamic var dataType: String
}
