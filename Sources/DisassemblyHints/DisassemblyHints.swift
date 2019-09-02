import Foundation

/**
 A collection of hints for the disassembly process.
 */
public struct DisassemblyHints<AddressType: BinaryInteger> {
  public init() {
  }

  public func toWireformat() throws -> Data {
    return try Hints.with { hints in
      hints.globals = globals.map { address, global in
        Global.with { proto in
          proto.address = UInt64(address)
          proto.name = global.name
          if let dataType = global.dataType {
            proto.datatype = dataType
          }
        }
      }
    }.serializedData()
  }

  public mutating func addGlobals(_ globals: [AddressType: String]) {
    self.globals.merge(globals.mapValues { _Global(stringLiteral: $0) }) { (global1, global2) in
      preconditionFailure("\(global1.name) would be overwritten by \(global2.name).")
    }
  }

  public mutating func addGlobal(at address: AddressType, named name: String) {
    if let existingGlobal = globals[address] {
      preconditionFailure("\(existingGlobal.name) would be overwritten by \(name).")
    }
    self.globals[address] = _Global(stringLiteral: name)
  }

  private struct _Global: ExpressibleByStringLiteral {
    let name: String
    let dataType: String?

    public init(stringLiteral: String) {
      self.name = stringLiteral
      let nameParts = self.name.split(separator: " ")
      if nameParts.count > 1 {
        self.dataType = String(nameParts[0])
      } else {
        self.dataType = nil
      }
    }
  }

  private var globals: [AddressType: _Global] = [:]
}
