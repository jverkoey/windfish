import Foundation

extension Disassembler {
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

  /** Registers a new global at the given address. */
  public func registerGlobal(at address: LR35902.Address, named name: String, dataType: String? = nil) {
    if let dataType: String = dataType, !dataType.isEmpty {
      precondition(dataTypes[dataType] != nil, "Data type is not registered.")
    }
    globals[address] = Global(name: name, dataType: dataType)

    if address < 0x4000 {
      registerLabel(at: address, in: 0x01, named: name)
      registerData(at: Cartridge.Location(address: address, bank: 0x01))
    }
  }
}
