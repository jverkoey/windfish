import Foundation

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
}

extension Disassembler {
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
  func trace(range: Range<Cartridge.Location>,
             cpu: LR35902 = LR35902(),
             step: ((LR35902.Instruction, Cartridge.Location, LR35902) -> Void)? = nil) {
    let bank: Cartridge.Bank = range.lowerBound.bank
    let upperBoundPc: LR35902.Address = range.upperBound.address

    // TODO: Evaluate whether recreating this on every trace is a memory / performance hog.
    let tracerMemory = TracerMemory(data: cartridgeData)

    cpu.pc = range.lowerBound.address
    tracerMemory.selectedBank = bank

    while cpu.pc < upperBoundPc {
      guard let instruction: LR35902.Instruction = self.instruction(at: Cartridge.Location(address: cpu.pc, bank: bank)) else {
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
      step?(instruction, location, cpu)

      cpu.pc = initialPc + LR35902.Address(truncatingIfNeeded: LR35902.InstructionSet.data(representing: instruction).count)
    }
  }
}

