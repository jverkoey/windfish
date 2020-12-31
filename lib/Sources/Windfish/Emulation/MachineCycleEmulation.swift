import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://gekkio.fi/files/gb-docs/gbctr.pdf

extension LR35902 {
  /** Advances the CPU by one machine cycle. */
  public func advance(memory: AddressableMemory) {
    // https://gekkio.fi/files/gb-docs/gbctr.pdf
    if isRunning {
      let machineInstruction = self.machineInstruction
      // Execution phase
      if nextAction == .continueExecution, let instructionEmulator = machineInstruction.instructionEmulator {
        machineInstruction.cycle += 1
        nextAction = instructionEmulator.advance(cpu: self, memory: memory, cycle: machineInstruction.cycle, sourceLocation: machineInstruction.sourceLocation!)
      } else {
        // No instruction was actually loaded into the CPU; let's switch to fetching one.
        nextAction = .fetchNext
      }
    }

    // The LR35902's fetch/execute overlap behavior means we load the next opcode on the same machine cycle as the
    // last instruction's execution.
    if nextAction == .fetchNext || nextAction == .fetchPrefix {
      let interrupts = interruptFlag.intersection(interruptEnable)
      if nextAction == .fetchNext && !interrupts.isEmpty {
        // Interrupt phase
        halted = false

        let sourceLocation = memory.sourceLocation(from: pc)
        nextAction = .continueExecution
        machineInstruction.instructionEmulator = LR35902.Emulation.interrupt(interrupts: interrupts)
        machineInstruction.spec = .interrupt(interrupts)
        machineInstruction.sourceLocation = sourceLocation

      } else if isRunning {
        // Fetch phase
        var sourceLocation = memory.sourceLocation(from: pc)
        let tableIndex = Int(truncatingIfNeeded: memory.read(from: pc))
        pc += 1
        let loadedSpec: Instruction.Spec
        if let spec = machineInstruction.spec, let prefixTable = InstructionSet.prefixTables[spec] {
          // Finish loading the prefix instruction.
          sourceLocation = machineInstruction.sourceLocation!
          loadedSpec = prefixTable[tableIndex]
          specIndex = 256 + tableIndex
        } else {
          loadedSpec = InstructionSet.table[tableIndex]
          specIndex = tableIndex
        }
        nextAction = .continueExecution

        machineInstruction.spec = loadedSpec
        machineInstruction.sourceLocation = sourceLocation
        let emulator = LR35902.Emulation.instructionEmulators[specIndex]
        machineInstruction.instructionEmulator = emulator
      }
    }

    // TODO: Verify this timing as I'm not confident it's being evaluated at the correct location.
    if imeScheduledCyclesRemaining > 0 {
      imeScheduledCyclesRemaining -= 1
      if imeScheduledCyclesRemaining <= 0 {
        ime = true
        imeScheduledCyclesRemaining = 0
      }
    }
  }
}

extension Gameboy {
  /** Advances the emulation by one machine cycle. */
  public func advance() {
    // DMA controller is always able to access memory directly.
    dmaController.advance(memory: memory)

    let proxyMemory: AddressableMemory = dmaController.oamLocked ? dmaProxy : memory
    cpu.advance(memory: proxyMemory)
    lcdController.advance(memory: proxyMemory)
  }

  /** Advances the emulation by one instruction. */
  public func advanceInstruction() {
    if cpu.machineInstruction.spec == nil {
      advance()
    }
    if let sourceLocation = cpu.machineInstruction.sourceLocation {
      while sourceLocation == cpu.machineInstruction.sourceLocation, !cpu.halted {
        advance()
      }
    }
  }
}
