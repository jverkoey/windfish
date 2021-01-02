import Foundation

final class GenericRAM: AddressableMemory {
  public var data: [LR35902.Address: UInt8] = [:]

  func read(from address: LR35902.Address) -> UInt8 {
    return data[address] ?? 0xff
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    data[address] = byte
  }

  func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
