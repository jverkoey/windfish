import Foundation

public struct TracerMemory: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    return 0x00
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
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
  @discardableResult
  func trace(range: Range<Gameboy.Cartridge.Location>,
             initialState: LR35902 = LR35902.zeroed(),
             step: ((LR35902.Instruction, Gameboy.Cartridge.Location, LR35902) -> Void)? = nil)
  -> [Gameboy.Cartridge.Location: LR35902] {
    var state = initialState

    (state.pc, state.bank) = Gameboy.Cartridge.addressAndBank(from: range.lowerBound)
    let upperBoundPc = Gameboy.Cartridge.addressAndBank(from: range.upperBound).address

    // TODO: Store this globally.
    var states: [Gameboy.Cartridge.Location: LR35902] = [:]

    while state.pc < upperBoundPc {
      guard let instruction = self.instruction(at: state.pc, in: state.bank) else {
        state.pc += 1
        continue
      }

      var memory: AddressableMemory = TracerMemory()
      let location = Gameboy.Cartridge.location(for: state.pc, in: state.bank)!
      let postState = state.emulate(instruction: instruction, memory: &memory)
      step?(instruction, location, postState)
      states[location] = postState
      state = postState
    }

    return states
  }
}

