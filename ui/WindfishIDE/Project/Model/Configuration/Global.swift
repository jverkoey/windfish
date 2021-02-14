import Foundation

import LR35902
import Windfish

final class Global: NSObject {
  internal init(name: String, address: LR35902.Address, dataType: String) {
    self.name = name
    self.address = address
    self.dataType = dataType
  }

  @objc dynamic var name: String
  @objc dynamic var address: LR35902.Address
  @objc dynamic var dataType: String

  func toWindfish() -> Windfish.Project.Global {
    return Windfish.Project.Global(name: name, address: address, dataType: dataType)
  }
}
