import Foundation

public final class Gameboy {
  public init() {
    self.lcdController = LCDController(oam: oam)
    self.dmaController = DMAController(oam: oam)
    self.memory = Memory(cpu: cpu, lcdController: lcdController, dmaController: dmaController, oam: oam, soundController: soundController, timer: timer)
    self.dmaProxy = DMAProxy(memory: memory)
  }

  // MARK: - Hardware

  /** The cartridge that is inserted into the Gameboy. */
  public var cartridge: Gameboy.Cartridge? {
    didSet {
      self.memory.cartridge = cartridge
    }
  }

  /** The Gameboy's central processing unit (CPU). */
  public let cpu = LR35902()

  /** A general read/write mechanism for the Gameboy's memory. */
  public let memory: Memory

  /** The Gameboy's liquid crystal display (LCD) controller. */
  public let lcdController: LCDController

  public var serialDataReceived: [UInt8] {
    get {
      return memory.ioRegisters.serialDataReceived
    }
  }

  /** The Gameboy's OAM DMA controller. */
  let dmaController: DMAController

  /** The Gameboy's sound controller. */
  let soundController = SoundController()

  /** The Gameboy's OAM. */
  let oam = OAM()

  let timer = Timer()

  let dmaProxy: DMAProxy

  // MARK: - Debugging

  /** Registers a memory tracer with the gameboy that can observe memory operations. */
  public func addMemoryTracer(_ tracer: AddressableMemory) {
    memory.tracers.append(tracer)
  }

  public var screenData: UnsafeMutableRawBufferPointer {
    return lcdController.registers.screenData
  }

  public var tileData: Data {
    return Data(lcdController.registers.tileData)
  }

  public static var tileDataRegionSize: Int {
    return LCDController.tileDataRegion.count
  }
}

final class DMAProxy: AddressableMemory {
  init(memory: AddressableMemory) {
    self.memory = memory
  }
  let memory: AddressableMemory

  func read(from address: LR35902.Address) -> UInt8 {
    switch address {
    // Addresses that are still accessible during DMA transfer
    case Gameboy.Memory.hramAddressableRange, DMAController.registerAddress:
      return memory.read(from: address)
    default:
      return 0xFF
    }
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    switch address {
    // Addresses that are still accessible during DMA transfer
    case Gameboy.Memory.hramAddressableRange, DMAController.registerAddress:
      memory.write(byte, to: address)
    default:
      break  // Do nothing.
    }
  }

  func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}

extension Gameboy {
  /** Advances the emulation by one machine cycle. */
  public func advance() {
    // DMA controller is always able to access memory directly.
    dmaController.advance(memory: memory)

    let proxyMemory: AddressableMemory = dmaController.oamLocked ? dmaProxy : memory
    cpu.advance(memory: proxyMemory)
    timer.advance(memory: proxyMemory)
    lcdController.advance(memory: proxyMemory)
  }

  /** Advances the emulation by one instruction. */
  public func advanceInstruction() {
    if cpu.machineInstruction.instructionEmulator == nil {
      // Initial bootstrap.
      advance()
    }
    if let sourceLocation = cpu.machineInstruction.sourceLocation {
      var maxCycle = cpu.machineInstruction.cycle
      while sourceLocation == cpu.machineInstruction.sourceLocation, maxCycle <= cpu.machineInstruction.cycle {
        advance()
        maxCycle = max(maxCycle, cpu.machineInstruction.cycle)
      }
    }
  }
}
