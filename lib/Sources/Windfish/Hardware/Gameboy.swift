import Foundation

public final class Gameboy {
  public init() {
    self.ppu = PPU(oam: oam)
    self.dmaController = DMAController(oam: oam)
    self.memory = Memory(cpu: cpu, lcdController: ppu, dmaController: dmaController, oam: oam, soundController: soundController, timer: timer)
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
  public let ppu: PPU

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
    return ppu.registers.screenData
  }

  public var tileData: Data {
    return Data(ppu.registers.tileData)
  }

  public static var tileDataRegionSize: Int {
    return PPU.tileDataRegion.count
  }

  struct CycleState: Equatable {
    let mcycle: MCycle
    let mode: PPU.LCDCMode
    let ly: UInt8
    var lyForComparison: UInt8?
    var coincidence: Bool = false
    var stat: UInt8
    var IF: UInt8 = 0

    static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.mode == rhs.mode && lhs.ly == rhs.ly && lhs.lyForComparison == rhs.lyForComparison && lhs.coincidence == rhs.coincidence && lhs.stat == rhs.stat && lhs.IF == rhs.IF
    }
  }
  var lineCycleStates: [CycleState] = []
  var lastPrintedScanline: UInt8 = 0
  var lastCoincidence: Bool = false
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
  // Timing types.
  typealias MCycle = Int
  typealias TCycle = Int

  /** Advances the emulation by one machine cycle. */
  public func advance() {
    // DMA controller is always able to access memory directly.
    dmaController.advance(memory: memory)

    // "While DMA Transfer is active, the source is not accessible."
    // - https://youtu.be/HyzD8pNlpwI?t=2948
    // TODO: Does this include timer + PPU? Or is just the CPU restricted from accessing source?
    let proxyMemory: AddressableMemory = dmaController.oamLocked ? dmaProxy : memory
    cpu.advance(memory: proxyMemory)
    timer.advance(memory: proxyMemory)
    ppu.advance(memory: proxyMemory)
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

  /** Advances the emulation by one machine cycle and tracks t-cycle-level state changes of the PPU. */
  public func advanceWithCycleTiming() {
    if ppu.lineCycleDriver.scanline != lastPrintedScanline {
      let ie = memory.read(from: LR35902.interruptEnableAddress)
      let iflag = memory.read(from: LR35902.interruptFlagAddress)
      let colWidth = 8
      print("scanline: \(ppu.lineCycleDriver.scanline > 0 ? ppu.lineCycleDriver.scanline - 1 : 153) lyc: \(ppu.registers.lyc) IE: \(ie.binaryString) IF: \(iflag.binaryString)")
      print("")
      print("mcycle:     " + lineCycleStates
              .map { "\($0.mcycle * 4)".padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))
      print("ly:         " + lineCycleStates
              .map { "\($0.ly)".padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))
      print("ly for lyc: " + lineCycleStates
              .map { ($0.lyForComparison != nil ? "\($0.lyForComparison!)" : "").padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))
      print("mode:       " + lineCycleStates
              .map { "\($0.mode.bits)".padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))
      print("stat:       " + lineCycleStates
              .map { "\($0.stat.binaryString)".padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))

      print("end state:")
      print("IF[lyc=lyc]:" + lineCycleStates
              .map { ($0.coincidence ? "1" : "").padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))
      print("if:         " + lineCycleStates
              .map { ($0.IF > 0 ? "\($0.IF.binaryString)" : "").padding(toLength: colWidth, withPad: " ", startingAt: 0) }
              .joined(separator: " "))

      print("")
      lineCycleStates.removeAll(keepingCapacity: true)
      lastPrintedScanline = ppu.lineCycleDriver.scanline
    }
    var cycleState = CycleState(
      mcycle: ppu.lineCycleDriver.tcycles / 4,
      mode: ppu.registers.lcdMode,
      ly: ppu.registers.ly,
      lyForComparison: ppu.lyForComparison,
      stat: ppu.registers.stat
    )

    advance()

    let iflag = memory.read(from: LR35902.interruptFlagAddress)
    cycleState.IF = iflag
    cycleState.coincidence = lastCoincidence != ppu.registers.coincidence && ppu.registers.coincidence
    if cycleState != lineCycleStates.last {
      lineCycleStates.append(cycleState)
    }
    lastCoincidence = ppu.registers.coincidence
  }

}
