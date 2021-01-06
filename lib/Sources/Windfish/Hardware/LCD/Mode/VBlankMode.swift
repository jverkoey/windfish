import Foundation

extension LCDController {
  final class VBlankMode {
    init(registers: LCDRegisters, lineCycleDriver: LineCycleDriver) {
      self.registers = registers
      self.lineCycleDriver = lineCycleDriver
    }

    private let registers: LCDRegisters
    private let lineCycleDriver: LineCycleDriver

    /** Starts the mode. */
    func start() {
      lineCycleDriver.cycles = 0
    }

    /** Executes a single machine cycle.  */
    func advance(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.cycles += 1

      var nextMode: LCDCMode? = nil

      if lineCycleDriver.cycles % LCDController.scanlineCycleLength == 0 {
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
