import Foundation

import Windfish

protocol EmulationObservers {
  func emulationDidAdvance()
}

extension ProjectDocument {
  /** Advances the emulation until the statement following the current one is reached. */
  func stepForward() {
    if emulating {
      return  // Ignore subsequent invocations.
    }
    emulating = true

    DispatchQueue.global(qos: .userInteractive).async {
      let gameboy = self.gameboy
      if case .call = gameboy.cpu.machineInstruction.spec {
        let nextAddress = gameboy.cpu.machineInstruction.sourceAddress()! + LR35902.InstructionSet.widths[gameboy.cpu.machineInstruction.spec!]!.total
        // Advance until we're ready to execute the next statement after the call.
        repeat {
          gameboy.advanceInstruction()
        } while self.emulating && gameboy.cpu.machineInstruction.sourceAddress() != nextAddress
      } else if case .halt = gameboy.cpu.machineInstruction.spec {
        let initialAddress = gameboy.cpu.machineInstruction.sourceAddress()!
        // Advance until an interrupt happens.
        // TODO: Do this on a thread.
        repeat {
          gameboy.advanceInstruction()
        } while self.emulating && gameboy.cpu.machineInstruction.sourceAddress() == initialAddress
      } else {
        gameboy.advanceInstruction()
      }

      DispatchQueue.main.sync {
        self.emulating = false
        self.emulationObservers.forEach { $0.emulationDidAdvance() }
      }
    }
  }
}
