import Foundation

extension LR35902.Emulation {
  final class interrupt: InstructionEmulator {
    init(interrupts: LR35902.Instruction.Interrupt) {
      self.interrupts = interrupts
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        cpu.sp -= 1
        memory.write(UInt8((cpu.pc & 0xFF00) >> 8), to: cpu.sp)
        return .continueExecution
      }
      if cycle == 2 {
        cpu.sp -= 1
        memory.write(UInt8(cpu.pc & 0x00FF), to: cpu.sp)
        return .continueExecution
      }
      var interrupts = self.interrupts
      if interrupts.contains(.vBlank) {
        interrupts.remove(.vBlank)
        cpu.pc = 0x0040
      } else if interrupts.contains(.lcdStat) {
        interrupts.remove(.lcdStat)
        cpu.pc = 0x0048
      } else if interrupts.contains(.timer) {
        interrupts.remove(.timer)
        cpu.pc = 0x0050
      } else if interrupts.contains(.serial) {
        interrupts.remove(.serial)
        cpu.pc = 0x0058
      } else if interrupts.contains(.joypad) {
        interrupts.remove(.joypad)
        cpu.pc = 0x0060
      }
      memory.write(interrupts.rawValue, to: LR35902.interruptFlagAddress)
      cpu.ime = false
      return .fetchNext
    }

    private let interrupts: LR35902.Instruction.Interrupt
  }
}
