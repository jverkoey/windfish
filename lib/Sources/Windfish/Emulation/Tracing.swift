import Foundation

public final class TracerMemory: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    return 0x00
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return Disassembler.sourceLocation(for: address, in: 0)
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
  func trace(range: Range<Gameboy.Cartridge.Location>,
             cpu: LR35902 = LR35902.zeroed(),
             step: ((LR35902.Instruction, Gameboy.Cartridge.Location, LR35902) -> Void)? = nil) {
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: range.lowerBound)
    cpu.pc = addressAndBank.address
    let bank = addressAndBank.bank
    let upperBoundPc = Gameboy.Cartridge.addressAndBank(from: range.upperBound).address

    while cpu.pc < upperBoundPc {
      guard let instruction = self.instruction(at: cpu.pc, in: bank) else {
        cpu.pc += 1
        continue
      }

      let memory: AddressableMemory = TracerMemory()
      let location = Gameboy.Cartridge.location(for: cpu.pc, in: bank)!
      cpu.emulate(instruction: instruction, memory: memory)
      step?(instruction, location, cpu)
    }
  }
}

