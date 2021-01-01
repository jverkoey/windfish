import Foundation

extension Gameboy {
  public final class Memory {
    public init(cpu: LR35902, lcdController: LCDController, dmaController: DMAController, oam: OAM, soundController: SoundController) {
      self.cpu = cpu
      self.lcdController = lcdController
      self.dmaController = dmaController
      self.oam = oam
      self.soundController = soundController
    }

    public var tracers = ContiguousArray<AddressableMemory>()

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
        case Memory.ramAddressableRange, Memory.echoRamAddressableRange:  return ram
        case Memory.hramAddressableRange: return hram
        case 0xFF00...0xFF07, 0xFF47...0xFF49:
          return ioRegisters
        case DMAController.registerAddress:
          return dmaController
        case LCDController.tileMapRegion, LCDController.tileDataRegion, LCDController.registerRegion1, LCDController.registerRegion2,
             OAM.addressableRange:
          return lcdController
        case SoundController.wavePatternRegion, SoundController.soundRegistersRegion:
          return soundController
        default:
          fatalError("No region mapped to this address.")
        }
      }
    }

    // MARK: - Mapping regions of memory

    private let hram = GenericRAM()
    private let ram = InternalRAM()
    private let ioRegisters = IORegisterMemory()
    private let dmaController: DMAController
    private let oam: OAM
    private let soundController: SoundController

    static let hramAddressableRange: ClosedRange<LR35902.Address> = 0xFF80...0xFFFE
    static let ramAddressableRange: ClosedRange<LR35902.Address> = 0xC000...0xDFFF
    static let echoRamAddressableRange: ClosedRange<LR35902.Address> = 0xE000...0xFDFF
  }
}

private final class InternalRAM: AddressableMemory {
  public var data: [LR35902.Address: UInt8] = [:]

  func read(from address: LR35902.Address) -> UInt8 {
    switch address {
    case Gameboy.Memory.ramAddressableRange:
      return data[address] ?? 0xff
    case Gameboy.Memory.echoRamAddressableRange:
      return data[address - (Gameboy.Memory.echoRamAddressableRange.lowerBound - Gameboy.Memory.ramAddressableRange.lowerBound)] ?? 0xff
    default:
      fatalError()
    }
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    switch address {
    case Gameboy.Memory.ramAddressableRange:
      data[address] = byte
    case Gameboy.Memory.echoRamAddressableRange:
      data[address - (Gameboy.Memory.echoRamAddressableRange.lowerBound - Gameboy.Memory.ramAddressableRange.lowerBound)] = byte
    default:
      fatalError()
    }
  }

  func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
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
