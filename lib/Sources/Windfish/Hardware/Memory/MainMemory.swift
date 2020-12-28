import Foundation

extension Gameboy {
  public final class Memory {
    public init(lcdController: LCDController) {
      self.lcdController = lcdController
    }

    public var tracers: [AddressableMemory] = []

    public var cartridge: Cartridge?
    public var lcdController: LCDController

    // MARK: - Memory mapping

    private subscript(address: LR35902.Address) -> AddressableMemory {
      get {
        switch address {
        case 0x0000...0x7FFF:
          return cartridge!
        case OAM.addressableRange:
          return oam
        case ramAddressableRange:
          return ram
        case hramAddressableRange:
          return hram
        case 0xFF05...0xFF26, 0xFF47...0xFF4B, 0xFFFF...0xFFFF:
          return ioRegisters
        case LCDController.tileMapRegion, LCDController.tileDataRegion, 0xFF40...0xFF45:
          return lcdController
        default:
          fatalError("No region mapped to this address.")
        }
      }
    }

    // MARK: - Mapping regions of memory

    private var hram = GenericRAM()
    private var ram = GenericRAM()
    private var ioRegisters = IORegisterMemory()
    private var oam = OAM()

    private let hramAddressableRange: ClosedRange<LR35902.Address> = 0xFF80...0xFFFE
    private let ramAddressableRange: ClosedRange<LR35902.Address> = 0xC000...0xDFFF
  }
}

extension Gameboy.Memory: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    for tracer in tracers {
      _ = tracer.read(from: address)
    }

    return self[address].read(from: address)
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    for index in tracers.indices {
      tracers[index].write(byte, to: address)
    }

    self[address].write(byte, to: address)
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return self[address].sourceLocation(from: address)
  }
}
