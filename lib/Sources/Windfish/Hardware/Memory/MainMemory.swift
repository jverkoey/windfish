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
      mapRegion(to: ram)
      mapRegion(to: oam)
    }

    public var tracers: [AddressableMemory] = []

    public func read(from address: LR35902.Address) -> UInt8 {
      for tracer in tracers {
        _ = tracer.read(from: address)
      }

      if let memory = mappedRegions.first(where: { range, _ in range.contains(address) })?.value {
        return memory.read(from: address)
      }
      fatalError("No region mapped to this address.")
    }

    public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
      for index in tracers.indices {
        tracers[index].write(byte, to: address)
      }

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
    private var ram = GenericRAM(addressableRanges: [0xC000...0xDFFF])
    private var oam = OAM()

    mutating func mapRegion(to memory: AddressableMemory) {
      for range in memory.addressableRanges {
        let intRange = Int(range.lowerBound)...Int(range.upperBound)
        precondition(mappedRegions[range] != nil || !mappedBytes.contains(integersIn: intRange),
                     "This map will partially overlap another region.")
        mappedBytes.insert(integersIn: intRange)

        mappedRegions[range] = memory
      }
    }
  }
}
