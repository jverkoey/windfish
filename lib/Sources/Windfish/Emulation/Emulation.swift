import Foundation

extension LR35902 {
  /**
   Emulates the given instruction and returns the advanced CPU state.

   - Parameter followControlFlow: If enabled, emulation will follow any transfers of control flow. Otherwise, control
   flow changes will be ignored and the instruction will be immediately stepped over.
   */
  func emulate(instruction: LR35902.Instruction, memory: AddressableMemory, followControlFlow: Bool = false) {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    let location = memory.sourceLocation(from: pc)
    let width = LR35902.InstructionSet.widths[instruction.spec]!.total

    switch instruction.spec {
    case .ld(let numeric, .imm8) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      self[numeric] = immediate
      registerTraces[numeric] = .init(sourceLocation: location)
      pc += width

    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      self[dst] = self[src] as UInt8
      registerTraces[dst] = registerTraces[src]
      pc += width

    case .add(let dst, let src) where registers16.contains(dst) && registers16.contains(src):
      let originalValue: UInt16 = self[dst]
      (self[dst], fcarry) = self[dst].addingReportingOverflow(self[src] as UInt16)
      fsubtract = false
      fhalfcarry = (((self[src] & UInt16(0x0FFF)) + (originalValue & 0x0FFF)) & 0b0001_0000_0000_0000) == 0b0001_0000_0000_0000
      registerTraces[dst] = registerTraces[src]
      pc += width

    case .ld(let dst, .imm16addr) where registers8.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      self[dst] = memory.read(from: immediate)
      registerTraces[dst] = .init(sourceLocation: location, loadAddress: immediate)
      pc += width

    case .ld(let dst, .imm16) where registers16.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      self[dst] = immediate
      registerTraces[dst] = .init(sourceLocation: location)
      pc += width

    case .ld(let dst, .ffimm8addr) where registers8.contains(dst):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      self[dst] = memory.read(from: address)
      registerTraces[dst] = .init(sourceLocation: location, loadAddress: address)
      pc += width

    case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      memory.write(self[numeric], to: address)
      pc += width

    case .ldi(.hladdr, .a):
      memory.write(a, to: hl)
      pc += width

    case .ldi(.a, .hladdr):
      a = memory.read(from: hl)
      pc += width

    case .xor(.a):
      a = 0
      registerTraces[.a] = .init(sourceLocation: location)
      pc += width

    case .xor(let numeric) where numeric == .imm8:
      guard case .imm8(let src) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      a = a ^ src
      registerTraces[.a] = .init(sourceLocation: location)
      pc += width

    case .xor(let numeric) where registers8.contains(numeric):
      a = a ^ self[numeric]
      registerTraces[.a] = .init(sourceLocation: location)
      pc += width

    case .and(let numeric) where registers8.contains(numeric):
      a = a & self[numeric]
      registerTraces[.a] = .init(sourceLocation: location)
      pc += width

    case .and(.imm8):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      a = a & immediate
      registerTraces[.a] = .init(sourceLocation: location)
      pc += width

    case .jp(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        pc = immediate
      } else {
        pc += width
      }

    case .call(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        let pcMSB = UInt8((pc & 0xFF00) >> 8)
        let pcLSB = UInt8(pc & 0x00FF)
        sp -= 1
        memory.write(pcMSB, to: sp)
        sp -= 1
        memory.write(pcLSB, to: sp)
        pc = immediate
      } else {
        pc += width
      }

    case .ld(.sp, .imm16):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      sp = immediate
      registerTraces[.sp] = .init(sourceLocation: location)
      pc += width

    case .ld(.a, .bcaddr):
      let address = LR35902.Address(b) << 8 | LR35902.Address(c)
      a = memory.read(from: address)
      registerTraces[.a] = .init(sourceLocation: location, loadAddress: address)
      pc += width

    case .ld(.bcaddr, .a):
      memory.write(a, to: LR35902.Address(b) << 8 | LR35902.Address(c))
      pc += width

    case .inc(let numeric) where registers16.contains(numeric):
      set(numeric16: numeric, to: get(numeric16: numeric) &+ 1)
      pc += width

    case .inc(let numeric) where registers8.contains(numeric):
      set(numeric8: numeric, to: get(numeric8: numeric) &+ 1)
      pc += width

    case .dec(let numeric) where registers8.contains(numeric):
      set(numeric8: numeric, to: get(numeric8: numeric) &- 1)
      pc += width

    case .dec(let numeric) where registers16.contains(numeric):
      set(numeric16: numeric, to: get(numeric16: numeric) &- 1)
      pc += width

    case .ld(.imm16addr, .sp):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      memory.write(UInt8(sp & 0xFF), to: immediate)
      memory.write(UInt8(sp >> 8), to: immediate + 1)
      pc += width

    case .rlca:
      let msb = (a & 0b1000_0000) >> 7
      a = (a << 1) | msb
      fcarry = (a & 0x01) != 0
      pc += width

    case .reti, .ret:
      registerTraces.removeValue(forKey: .a)
      registerTraces.removeValue(forKey: .bc)
      registerTraces.removeValue(forKey: .hl)
      registerTraces.removeValue(forKey: .sp)
      pc += width

    case .cb(.res(let bit, let numeric)) where registers8.contains(numeric):
      self[numeric] = (self[numeric] as UInt8) & ~(1 << bit.rawValue)
      pc += width

    case .cp(.imm8):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      fsubtract = true
      let result = a.subtractingReportingOverflow(immediate)
      fzero = result.partialValue == 0
      fcarry = result.overflow
      fhalfcarry = (a & 0x0f) < (immediate & 0x0f)
      pc += width

    case .nop:
      pc += width

    default:
      if followControlFlow {
        preconditionFailure("Unhandled instruction.")
      }
      pc += width
    }
  }
}
