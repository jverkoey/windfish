import Foundation

public struct GenericRAM: AddressableMemory {
  public var addressableRanges: [ClosedRange<LR35902.Address>]
  public var data: [LR35902.Address: UInt8] = [:]

  init(addressableRanges: [ClosedRange<LR35902.Address>]) {
    self.addressableRanges = addressableRanges
  }

  public func read(from address: LR35902.Address) -> UInt8 {
    return data[address]!
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    data[address] = byte
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
