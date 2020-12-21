import Foundation

extension Gameboy {
  public struct Memory: AddressableMemory {
    public init() {
      let ioMemory = IORegisterMemory()
      mappedRegions[LR35902.Address(0xFF00)...LR35902.Address(0xFF7F)] = ioMemory
      mappedRegions[LR35902.Address(0xFFFF)...LR35902.Address(0xFFFF)] = ioMemory
    }

    public var mappedRegions: [ClosedRange<LR35902.Address>: AddressableMemory] = [:]
    public var hram: [LR35902.Address: UInt8] = [:]

    public func read(from address: LR35902.Address) -> UInt8 {
      if let memory = mappedRegions.first(where: { range, _ in range.contains(address) })?.value {
        return memory.read(from: address)
      }
      if address >= 0xFF80 && address <= 0xFFFE {
        // HRAM
        return hram[address] ?? 0x00
      }
      preconditionFailure("No region mapped to this address.")
      return 0xff
    }

    public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
      if var mappedRegion = mappedRegions.first(where: { range, _ in range.contains(address) }) {
        mappedRegion.value.write(byte, to: address)
        mappedRegions[mappedRegion.key] = mappedRegion.value
        return
      }

      if address >= 0xFF80 && address <= 0xFFFE {
        // HRAM
        hram[address] = byte
        return
      }

      preconditionFailure("No region mapped to this address.")
    }
  }
}
