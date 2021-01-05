import Foundation

extension LR35902.Emulation {
  final class interrupt: InstructionEmulator {
    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        interrupts = LR35902.Instruction.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
        return .continueExecution
      }
      if cycle == 2 {
        let enabled = LR35902.Instruction.Interrupt(rawValue: memory.read(from: LR35902.interruptEnableAddress))
        let requestedInterrupts = enabled.intersection(interrupts)
        if requestedInterrupts.isEmpty {
          return .fetchNext
        }
        if requestedInterrupts.contains(.vBlank) {
          interrupts.remove(.vBlank)
          targetpc = 0x0040
        } else if requestedInterrupts.contains(.lcdStat) {
          interrupts.remove(.lcdStat)
          targetpc = 0x0048
        } else if requestedInterrupts.contains(.timer) {
          interrupts.remove(.timer)
          targetpc = 0x0050
        } else if requestedInterrupts.contains(.serial) {
          interrupts.remove(.serial)
          targetpc = 0x0058
        } else if requestedInterrupts.contains(.joypad) {
          interrupts.remove(.joypad)
          targetpc = 0x0060
        }
        memory.write(interrupts.rawValue, to: LR35902.interruptFlagAddress)
        cpu.ime = false
        return .continueExecution
      }
      if cycle == 3 {
        cpu.sp &-= 1
        memory.write(UInt8((cpu.pc & 0xFF00) >> 8), to: cpu.sp)
        return .continueExecution
      }
      if cycle == 4 {
        cpu.sp &-= 1
        memory.write(UInt8(cpu.pc & 0x00FF), to: cpu.sp)
        return .continueExecution
      }
      cpu.pc = targetpc
      return .fetchNext
    }

    private var interrupts: LR35902.Instruction.Interrupt = .init()
    private var targetpc: LR35902.Address = 0
  }
}
