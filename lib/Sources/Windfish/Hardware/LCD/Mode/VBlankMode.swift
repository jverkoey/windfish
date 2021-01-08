import Foundation

extension PPU {
  final class VBlankMode: PPUMode {
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

      if lineCycleDriver.cycles >= PPU.scanlineCycleLength {
        lineCycleDriver.cycles = 0
        lineCycleDriver.scanline += 1

        if lineCycleDriver.scanline >= 154 {
          lineCycleDriver.scanline = 0
          registers.requestOAMInterruptIfNeeded(memory: memory)
          nextMode = .searchingOAM
        }
      }

      return nextMode
    }
  }
}
