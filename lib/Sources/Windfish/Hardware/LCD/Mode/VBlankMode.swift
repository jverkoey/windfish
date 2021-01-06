import Foundation

extension LCDController {
  final class VBlankMode {
    init(registers: LCDRegisters) {
      self.registers = registers
    }

    private let registers: LCDRegisters
    private var cycles = 0

    var finished: Bool {
      return registers.ly >= 154
    }

    /** Starts the mode. */
    func start() {
      cycles = 0
    }

    /** Executes a single machine cycle.  */
    func advance(memory: AddressableMemory) -> LCDCMode? {
      cycles += 1

      var nextMode: LCDCMode? = nil

      if cycles % LCDController.scanlineCycleLength == 0 {
        registers.ly += 1

        if registers.ly >= 154 {
          registers.ly = 0
          registers.requestOAMInterruptIfNeeded(memory: memory)

          nextMode = .searchingOAM
        }

        registers.requestCoincidenceInterruptIfNeeded(memory: memory)
      }

      return nextMode
    }
  }
}
