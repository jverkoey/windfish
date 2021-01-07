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

        // TODO: Evaluate whether line 153 needs to treated as line 0 for lcd STAT purposes.
        // - http://forums.nesdev.com/viewtopic.php?f=20&t=13727
        // - https://github.com/shonumi/gbe-plus/commit/c878372d271439e093ce0347fc92a39050090680
        // - https://github.com/spec-chum/SpecBoy/blob/master/SpecBoy/Ppu.cs
        // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L1357-L1378
        // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L178-L182

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
