import Foundation

public struct DisassemblyRequest<AddressType: BinaryInteger> {
  private let data: Data
  public init(data: Data) {
    self.data = data
  }

  public func toWireformat() throws -> Data {
    return try Disassembly_Request.with { request in
      request.binary = data
      request.hints = Disassembly_Hints.with { hints in

        hints.globals = globals.map { address, global in
          Disassembly_Global.with { proto in
            proto.address = UInt64(address)
            proto.name = global.name
            if let dataType = global.dataType {
              proto.datatype = dataType
            }
          }
        }

      }
    }.serializedData()
  }

  public mutating func addGlobals(_ globals: [AddressType: String]) {
    self.globals.merge(globals.mapValues { Global(stringLiteral: $0) }) { (global1, global2) in
      preconditionFailure("\(global1.name) would be overwritten by \(global2.name).")
    }
  }

  public mutating func addGlobal(at address: AddressType, named name: String) {
    if let existingGlobal = globals[address] {
      preconditionFailure("\(existingGlobal.name) would be overwritten by \(name).")
    }
    self.globals[address] = Global(stringLiteral: name)
  }

  private struct Global: ExpressibleByStringLiteral {
    let name: String
    let dataType: String?

    public init(stringLiteral: String) {
      let nameParts = stringLiteral.split(separator: " ")
      if nameParts.count > 1 {
        self.name = String(nameParts[1])
        self.dataType = String(nameParts[0])
      } else {
        self.name = stringLiteral
        self.dataType = nil
      }
    }
  }

  private var globals: [AddressType: Global] = [:]
}
