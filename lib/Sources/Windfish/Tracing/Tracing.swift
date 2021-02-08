import Foundation

import LR35902

/** A region of addressable memory can be read from and written to. */
protocol TraceableMemory: class {
  /** Read from the given address and return the resulting byte, if it's known. */
  func read(from address: LR35902.Address) -> UInt8?

  /** Write a byte to the given address. Writing nil will clear any known value at the given address. */
  func write(_ byte: UInt8?, to address: LR35902.Address)

  /** Returns a source code location for the given address based on the current memory configuration. */
  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation

  /** Trace information for a given register. */
  var registerTraces: [LR35902.Instruction.Numeric: [LR35902.RegisterTrace]] { get set }
}

/** A representation of an object that is able to disassemble instructions from a given cartridge location. */
protocol InstructionDisassembler: class {
  func instruction(at location: Cartridge.Location) -> LR35902.Instruction?
}

extension LR35902 {
  /** Trace information for a specific register. */
  enum RegisterTrace: Equatable {
    /** The register's value was stored to an address in memory. */
    case storeToAddress(LR35902.Address)

    /** The register's value was loaded from an address in memory. */
    case loadFromAddress(LR35902.Address)

    /** The register's value was loaded from an immediate at some source location. */
    case loadImmediateFromSourceLocation(Gameboy.SourceLocation)

    /** The register's value was modified at some source location. */
    case mutationWithImmediateAtSourceLocation(Gameboy.SourceLocation)

    /** The register's value was modified at some source location. */
    case mutationFromAddress(Gameboy.SourceLocation)
  }
}

private final class TracerMemory: TraceableMemory {
  init(data: Data) {
    self.data = data
  }
  let data: Data
  var mutatedMemory: [LR35902.Address: UInt8] = [:]

  var selectedBank: Cartridge.Bank = 0

  func read(from address: LR35902.Address) -> UInt8? {
    let intAddress = Int(truncatingIfNeeded: address)
    // Read-only memory (ROM) bank 00
    if address <= 0x3FFF {
      guard intAddress < data.count else {
        return 0xff
      }
      return data[intAddress]
    }

    // Read-only memory (ROM) bank 01-7F
    if address >= 0x4000 && address <= 0x7FFF {
      let location = Cartridge.Location(address: address, bank: selectedBank)
      guard location.index < data.count else {
        return 0xff
      }
      return data[location.index]
    }

    return mutatedMemory[address]
  }

  func write(_ byte: UInt8?, to address: LR35902.Address) {
    mutatedMemory[address] = byte
  }

  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation {
    return .cartridge(Cartridge.Location(address: address, bank: selectedBank))
  }

  var registerTraces: [LR35902.Instruction.Numeric : [LR35902.RegisterTrace]] = [:]
}

extension LR35902 {
  // TODO: Extract this engine into a generic emulator so that the following code can be debugged in an interactive session:
  /*
   ; Store the read joypad state into c
   ld   c, a                                    ; $282A (00): ReadJoypadState $4F
   ld   a, [hPreviousJoypadState]               ; $282B (00): ReadJoypadState $F0 $CB
   xor  c                                       ; $282D (00): ReadJoypadState $A9
   and  c                                       ; $282E (00): ReadJoypadState $A1
   ld   [hJoypadState], a                       ; $282F (00): ReadJoypadState $E0 $CC
   ld   a, c                                    ; $2831 (00): ReadJoypadState $79
   ld   [hPreviousJoypadState], a               ; $2832 (00): ReadJoypadState $E0 $CB
   */
  /**
   Traces execution of the instructions within the given range starting from an initial CPU state.

   The returned dictionary is a mapping of cartridge locations to the post-execution CPU state for the instruction at
   that location.
   */
  class func trace(range: Range<Cartridge.Location>,
                   cpu: LR35902 = LR35902(),
                   cartridgeData: Data,
                   disassembler: InstructionDisassembler,
                   step: ((LR35902.Instruction, Cartridge.Location, LR35902, TraceableMemory) -> Void)? = nil) {
    let bank: Cartridge.Bank = range.lowerBound.bank
    let upperBoundPc: LR35902.Address = range.upperBound.address

    // TODO: Evaluate whether recreating this on every trace is a memory / performance hog.
    let tracerMemory = TracerMemory(data: cartridgeData)

    cpu.pc = range.lowerBound.address
    tracerMemory.selectedBank = bank

    while cpu.pc < upperBoundPc {
      guard let instruction: LR35902.Instruction = disassembler.instruction(at: Cartridge.Location(address: cpu.pc, bank: bank)) else {
        cpu.pc &+= 1
        continue
      }

      let initialPc: LR35902.Address = cpu.pc

      let location: Cartridge.Location = Cartridge.Location(address: cpu.pc, bank: bank)
      let sourceLocation: Gameboy.SourceLocation = Gameboy.SourceLocation.cartridge(location)
      let opCodeBytes = LR35902.InstructionSet.opcodeBytes[instruction.spec]!
      let opcodeIndex = opCodeBytes.count > 1 ? (256 + Int(truncatingIfNeeded: opCodeBytes[1])) : Int(truncatingIfNeeded: opCodeBytes[0])
      let emulator = LR35902.Emulation.instructionEmulators[opcodeIndex]

      cpu.pc += LR35902.Address(truncatingIfNeeded: opCodeBytes.count)

      emulator.emulate(cpu: cpu, memory: tracerMemory, sourceLocation: sourceLocation)
      step?(instruction, location, cpu, tracerMemory)

      cpu.pc = initialPc + LR35902.InstructionSet.widths[instruction.spec]!.opcode
    }
  }
}
