import Foundation

public final class Gameboy {
  public init() {
    self.memory = Memory(lcdController: lcdController)
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
  let lcdController = LCDController()

  // MARK: - Debugging

  /** Registers a memory tracer with the gameboy that can observe memory operations. */
  public func addMemoryTracer(_ tracer: AddressableMemory) {
    memory.tracers.append(tracer)
  }
}

extension Gameboy: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    return memory.read(from: address)
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    memory.write(byte, to: address)
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return memory.sourceLocation(from: address)
  }
}
