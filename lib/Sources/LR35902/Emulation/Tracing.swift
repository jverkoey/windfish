import Foundation

extension LR35902.Disassembly {
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
  func trace(range: Range<LR35902.Cartridge.Location>,
             initialState: LR35902.CPUState = LR35902.CPUState(),
             step: ((LR35902.Instruction, LR35902.Cartridge.Location, LR35902.CPUState) -> Void)? = nil)
  -> [LR35902.Cartridge.Location: LR35902.CPUState] {
    var state = initialState

    (state.pc, state.bank) = LR35902.Cartridge.addressAndBank(from: range.lowerBound)
    let upperBoundPc = LR35902.Cartridge.addressAndBank(from: range.upperBound).address

    // TODO: Store this globally.
    var states: [LR35902.Cartridge.Location: LR35902.CPUState] = [:]

    while state.pc < upperBoundPc {
      guard let instruction = self.instruction(at: state.pc, in: state.bank) else {
        state.pc += 1
        continue
      }

      let location = LR35902.Cartridge.location(for: state.pc, in: state.bank)!

      let postState = state.emulate(instruction: instruction)

      step?(instruction, location, postState)
      states[location] = postState

      state = postState
    }

    return states
  }
}

