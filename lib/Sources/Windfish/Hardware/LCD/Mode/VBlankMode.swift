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
      lineCycleDriver.tcycles = 0
    }

    /** Executes a single t-cycle.  */
    func tick(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.tcycles += 1

      var nextMode: LCDCMode? = nil

      if lineCycleDriver.tcycles >= PPU.TCycleTiming.scanline {
        lineCycleDriver.tcycles = 0
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
