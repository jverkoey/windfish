import Foundation

extension PPU {
  final class HBlankMode: PPUMode {
    init(registers: LCDRegisters, lineCycleDriver: LineCycleDriver) {
      self.registers = registers
      self.lineCycleDriver = lineCycleDriver
    }

    private let registers: LCDRegisters
    private let lineCycleDriver: LineCycleDriver

    /** Starts the mode. */
    func start() {}

    /** Executes a single t-cycle.  */
    func tick(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.tcycles += 1

      var nextMode: LCDCMode? = nil

      if lineCycleDriver.tcycles >= PPU.TCycleTiming.scanline {
        lineCycleDriver.scanline += 1
        if lineCycleDriver.scanline < 144 {
          nextMode = .searchingOAM
        } else {
          // No more lines to draw.
          nextMode = .vblank
        }
      }

      return nextMode
    }
  }
}
