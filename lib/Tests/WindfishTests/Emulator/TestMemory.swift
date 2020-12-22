import Foundation
import Windfish

/** Circumvent immutability of the TestMemory struct by tracking reads in a class instance. */
class MemoryReadTracer {
  var reads: [LR35902.Address] = []
}

struct TestMemory: AddressableMemory {
  public let addressableRanges: [ClosedRange<LR35902.Address>] = [
    0x0000...0xFFFF
  ]

  init(defaultReadValue: UInt8 = 0x00) {
    self.defaultReadValue = defaultReadValue
  }
  func read(from address: LR35902.Address) -> UInt8 {
    readMonitor.reads.append(address)
    return defaultReadValue
  }

  mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    writes.append(WriteOp(byte: byte, address: address))
  }

  var defaultReadValue: UInt8 = 0x00
  var readMonitor = MemoryReadTracer()
  struct WriteOp: Equatable {
    let byte: UInt8
    let address: LR35902.Address
  }
  var writes: [WriteOp] = []
}
