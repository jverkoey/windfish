import Foundation

public struct IORegisterMemory: AddressableMemory {
  enum IOAddresses: LR35902.Address {
    case TIMA = 0xFF05
    case TMA  = 0xFF06
    case TAC  = 0xFF07
    case NR10 = 0xFF10
    case NR11 = 0xFF11
    case NR12 = 0xFF12
    case NR14 = 0xFF14
    case NR21 = 0xFF16
    case NR22 = 0xFF17
    case NR24 = 0xFF19
    case NR30 = 0xFF1A
    case NR31 = 0xFF1B
    case NR32 = 0xFF1C
    case NR33 = 0xFF1E
    case NR41 = 0xFF20
    case NR42 = 0xFF21
    case NR43 = 0xFF22
    case NRSomething = 0xFF23
    case NR50 = 0xFF24
    case NR51 = 0xFF25
    case NR52 = 0xFF26
    case LCDC = 0xFF40
    case SCY  = 0xFF42
    case SCX  = 0xFF43
    case LYC  = 0xFF45
    case BGP  = 0xFF47
    case OBP0 = 0xFF48
    case OBP1 = 0xFF49
    case WY   = 0xFF4A
    case WX   = 0xFF4B
    case IE   = 0xFFFF
  }
  var values: [IOAddresses: UInt8] = [
    .TIMA: 0x00,
    .TMA:  0x00,
    .TAC:  0x00,
    .NR10: 0x80,
    .NR11: 0xBF,
    .NR12: 0xF3,
    .NR14: 0xBF,
    .NR21: 0x3F,
    .NR22: 0x00,
    .NR24: 0xBF,
    .NR30: 0x7F,
    .NR31: 0xFF,
    .NR32: 0x9F,
    .NR33: 0xBF,
    .NR41: 0xFF,
    .NR42: 0x00,
    .NR43: 0x00,
    .NRSomething: 0xBF,
    .NR50: 0x77,
    .NR51: 0xF3,
    .NR52: 0xF1,
    .LCDC: 0x91,
    .SCY:  0x00,
    .SCX:  0x00,
    .LYC:  0x00,
    .BGP:  0xFC,
    .OBP0: 0xFF,
    .OBP1: 0xFF,
    .WY:   0x00,
    .WX:   0x00,
    .IE:   0x00,
  ]
  public func read(from address: LR35902.Address) -> UInt8 {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    return values[ioAddress]!
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    precondition(values[ioAddress] != nil, "Writing to invalid register.")
    values[ioAddress] = byte
  }
}

public struct MainMemory: AddressableMemory {
  public init() {
    let ioMemory = IORegisterMemory()
    mappedRegions[LR35902.Address(0xFF00)...LR35902.Address(0xFF7F)] = ioMemory
    mappedRegions[LR35902.Address(0xFFFF)...LR35902.Address(0xFFFF)] = ioMemory
  }

  public var mappedRegions: [ClosedRange<LR35902.Address>: AddressableMemory] = [:]

  public func read(from address: LR35902.Address) -> UInt8 {
    if let memory = mappedRegions.first(where: { range, _ in range.contains(address) })?.value {
      return memory.read(from: address)
    }
    preconditionFailure("No region mapped to this address.")
    return 0xff
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    guard var mappedRegion = mappedRegions.first(where: { range, _ in range.contains(address) }) else {
      preconditionFailure("No region mapped to this address.")
    }
    mappedRegion.value.write(byte, to: address)
    mappedRegions[mappedRegion.key] = mappedRegion.value
  }
}

extension LR35902 {
  /**
   Emulates the given instruction and returns the advanced CPU state.

   - Parameter followControlFlow: If enabled, emulation will follow any transfers of control flow. Otherwise, control
   flow changes will be ignored and the instruction will be immediately stepped over.
   */
  public func emulate(instruction: LR35902.Instruction, memory: inout AddressableMemory, followControlFlow: Bool = false) -> LR35902 {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    let location = Gameboy.Cartridge.location(for: pc, in: bank)!
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
      state[dst] = memory.read(from: immediate)
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
      state[dst] = memory.read(from: address)
      state.registerTraces[dst] = .init(sourceLocation: location, loadAddress: address)
      state.pc += width

    case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      memory.write(state[numeric], to: address)
      state.pc += width

    case .ldi(.hladdr, .a):
      memory.write(state.a, to: state.hl)
      state.pc += width

    case .ldi(.a, .hladdr):
      state.a = memory.read(from: state.hl)
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
        memory.write(pcMSB, to: state.sp)
        state.sp -= 1
        memory.write(pcLSB, to: state.sp)
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
