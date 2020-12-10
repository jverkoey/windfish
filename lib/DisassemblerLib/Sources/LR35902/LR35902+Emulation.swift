import Foundation

extension LR35902 {
  func logic(for spec: Instruction.Spec) -> ((LR35902, Instruction) -> Void) {
    switch spec {
    case let .jp(condition, .imm16):
      if condition != nil {
        preconditionFailure()
      } else {
        return { cpu, instruction in
          guard case let .imm16(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          cpu.pc = immediate
        }
      }
      break
    default:
      preconditionFailure()
    }
  }
}
