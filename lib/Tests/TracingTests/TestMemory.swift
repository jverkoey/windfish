import Foundation

import LR35902
import Tracing

class TestMemory: TraceableMemory {
  public let addressableRanges: [ClosedRange<LR35902.Address>] = [
    0x0000...0xFFFF
  ]

  init(defaultReadValue: UInt8 = 0x00) {
    self.defaultReadValue = defaultReadValue
  }
  func read(from address: LR35902.Address) -> UInt8? {
    reads.append(address)
    return storage[address] ?? defaultReadValue
  }

  func write(_ byte: UInt8?, to address: LR35902.Address) {
    guard !ignoreWrites else {
      return
    }
    writes.append(WriteOp(byte: byte, address: address))
    storage[address] = byte
  }

  func sourceLocation(from address: LR35902.Address) -> Tracer.SourceLocation {
    if address < 0x8000 {
      return .cartridge(Cartridge.Location(address: address, bank: 0x01))
    }
    return .memory(address)
  }

  var registerTraces: [LR35902.Instruction.Numeric : [LR35902.RegisterTrace]] = [:]

  var defaultReadValue: UInt8 = 0x00
  var reads: [LR35902.Address] = []
  struct WriteOp: Equatable {
    let byte: UInt8?
    let address: LR35902.Address
  }
  var writes: [WriteOp] = []
  var storage: [LR35902.Address: UInt8] = [:]
  var ignoreWrites = false
}
