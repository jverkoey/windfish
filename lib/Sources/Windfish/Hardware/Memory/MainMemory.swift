import Foundation

extension Gameboy {
  public final class Memory {
    public init(cpu: LR35902, lcdController: LCDController) {
      self.cpu = cpu
      self.lcdController = lcdController
    }

    public var tracers: [AddressableMemory] = []

    public var cartridge: Cartridge?
    public let cpu: LR35902
    public let lcdController: LCDController

    // MARK: - Memory mapping

    private subscript(address: LR35902.Address) -> AddressableMemory {
      get {
        switch address {
        case Gameboy.Cartridge.romBankRegion, Gameboy.Cartridge.ramBankRegion:
          return cartridge!
        case LR35902.interruptEnableAddress, LR35902.interruptFlagAddress:
          return cpu
        case OAM.addressableRange:
          return oam
        case ramAddressableRange:
          return ram
        case hramAddressableRange:
          return hram
        case 0xFF05...0xFF07, 0xFF10...0xFF26, 0xFF47...0xFF4B:
          return ioRegisters
        case LCDController.tileMapRegion, LCDController.tileDataRegion, 0xFF40...0xFF46:
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
