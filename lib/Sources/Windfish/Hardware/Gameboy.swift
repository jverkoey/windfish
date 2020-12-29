import Foundation

public final class Gameboy {
  public init() {
    self.lcdController = LCDController(oam: oam)
    self.dmaController = DMAController(oam: oam)
    self.memory = Memory(cpu: cpu, lcdController: lcdController, dmaController: dmaController, oam: oam, soundController: soundController)
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
  let lcdController: LCDController

  /** The Gameboy's OAM DMA controller. */
  let dmaController: DMAController

  /** The Gameboy's sound controller. */
  let soundController = SoundController()

  /** The Gameboy's OAM. */
  let oam = OAM()

  // MARK: - Debugging

  /** Registers a memory tracer with the gameboy that can observe memory operations. */
  public func addMemoryTracer(_ tracer: AddressableMemory) {
    memory.tracers.append(tracer)
  }
}
