import Foundation

extension LR35902.CPUState {
  /**
   Emulates the given instruction and returns the advanced CPU state.

   - Parameter followControlFlow: If enabled, emulation will follow any transfers of control flow. Otherwise, control
   flow changes will be ignored and the instruction will be immediately stepped over.
   */
  public func emulate(instruction: LR35902.Instruction, followControlFlow: Bool = false) -> LR35902.CPUState {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    let location = LR35902.Cartridge.location(for: pc, in: bank)!
    let width = LR35902.InstructionSet.widths[instruction.spec]!.total

    var state = self

    switch instruction.spec {
    case .ld(let numeric, .imm8) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[numeric] = immediate
      state.registerTraces[numeric] = .init(sourceLocation: location)
      state.pc += width

    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      state[dst] = state[src] as UInt8
      state.registerTraces[dst] = state.registerTraces[src]
      state.pc += width

    case .ld(let dst, .imm16addr) where registers8.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = state.ram[immediate] ?? 0
      state.registerTraces[dst] = .init(sourceLocation: location, loadAddress: immediate)
      state.pc += width

    case .ld(let dst, .imm16) where registers16.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = immediate
      state.registerTraces[dst] = .init(sourceLocation: location)
      state.pc += width

    case .ld(let dst, .ffimm8addr) where registers8.contains(dst):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      state[dst] = ram[address] ?? 0
      state.registerTraces[dst] = .init(sourceLocation: location, loadAddress: address)
      state.pc += width

    case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      state.ram[address] = state[numeric]
      state.pc += width

    case .ldi(.hladdr, .a):
      state.ram[state.hl] = state.a
      state.pc += width

    case .ldi(.a, .hladdr):
      state.a = state.ram[state.hl] ?? 0
      state.pc += width

    case .xor(.a):
      state.a = 0
      state.registerTraces[.a] = .init(sourceLocation: location)
      state.pc += width

    case .xor(let numeric) where numeric == .imm8:
      guard case .imm8(let src) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state.a = state.a ^ src
      state.registerTraces[.a] = .init(sourceLocation: location)
      state.pc += width

    case .xor(let numeric) where registers8.contains(numeric):
      state.a = state.a ^ state[numeric]
      state.registerTraces[.a] = .init(sourceLocation: location)
      state.pc += width

    case .and(let numeric) where registers8.contains(numeric):
      state.a = state.a & state[numeric]
      state.registerTraces[.a] = .init(sourceLocation: location)
      state.pc += width

    case .and(.imm8):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state.a = state.a & immediate
      state.registerTraces[.a] = .init(sourceLocation: location)
      state.pc += width

    case .jp(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        state.pc = immediate
      } else {
        state.pc += width
      }

    case .call(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        let pcMSB = UInt8((state.pc & 0xFF00) >> 8)
        let pcLSB = UInt8(state.pc & 0x00FF)
        state.sp -= 1
        state.ram[state.sp] = pcMSB
        state.sp -= 1
        state.ram[state.sp] = pcLSB
        state.pc = immediate
      } else {
        state.pc += width
      }

    case .ld(.sp, .imm16):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state.sp = immediate
      state.registerTraces[.sp] = .init(sourceLocation: location)
      state.pc += width

    case .reti, .ret:
      state.registerTraces.removeValue(forKey: .a)
      state.registerTraces.removeValue(forKey: .bc)
      state.registerTraces.removeValue(forKey: .hl)
      state.registerTraces.removeValue(forKey: .sp)
      state.pc += width

    case .cb(.res(let bit, let numeric)) where registers8.contains(numeric):
      state[numeric] = (state[numeric] as UInt8) & ~(1 << bit.rawValue)
      state.pc += width

    default:
      state.pc += width
    }

    return state
  }
}
