import Foundation

import LR35902
import Tracing

extension Disassembler.MutableConfiguration {
  final class Global {
    let name: String
    let dataType: String?

    init(name: String, dataType: String? = nil) {
      self.name = name
      guard let dataType = dataType, !dataType.isEmpty else {
        self.dataType = nil
        return
      }
      self.dataType = dataType
    }
  }

  func allGlobals() -> [LR35902.Address: Disassembler.MutableConfiguration.Global] {
    return globals
  }

  func global(at address: LR35902.Address) -> Disassembler.MutableConfiguration.Global? {
    return globals[address]
  }

  /** Registers a new global at the given address. */
  public func registerGlobal(at address: LR35902.Address, named name: String, dataType: String? = nil) {
    if let dataType: String = dataType, !dataType.isEmpty {
      precondition(datatypeExists(named: dataType), "Data type is not registered.")
    }
    globals[address] = Global(name: name, dataType: dataType)

    if address < 0x4000 {
      let location = Cartridge.Location(address: address, bank: 0x01)
      registerLabel(at: location, named: name)
    }
  }
}
