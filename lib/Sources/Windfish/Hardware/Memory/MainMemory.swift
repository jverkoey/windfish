import Foundation

extension Gameboy {
  public struct Memory: AddressableMemory {
    public let addressableRanges: [ClosedRange<LR35902.Address>] = [
      0x0000...0xFFFF
    ]

    public init() {
      mapRegion(to: IORegisterMemory())
      mapRegion(to: LCDController())
      mapRegion(to: hram)
    }

    public func read(from address: LR35902.Address) -> UInt8 {
      if let memory = mappedRegions.first(where: { range, _ in range.contains(address) })?.value {
        return memory.read(from: address)
      }
      fatalError("No region mapped to this address.")
    }

    public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
      if var mappedRegion = mappedRegions.first(where: { range, _ in range.contains(address) }) {
        mappedRegion.value.write(byte, to: address)
        mappedRegions[mappedRegion.key] = mappedRegion.value
        return
      }
      fatalError("No region mapped to this address.")
    }

    // MARK: - Mapping regions of memory

    private var mappedRegions: [ClosedRange<LR35902.Address>: AddressableMemory] = [:]
    private var mappedBytes = IndexSet()
    private var hram = GenericRAM(addressableRanges: [0xFF80...0xFFFE])

    private mutating func mapRegion(to memory: AddressableMemory) {
      for range in memory.addressableRanges {
        let intRange = Int(range.lowerBound)...Int(range.upperBound)
        precondition(!mappedBytes.contains(integersIn: intRange), "Memory is already mapped to this region.")
        mappedBytes.insert(integersIn: intRange)

        mappedRegions[range] = memory
      }
    }
  }
}
