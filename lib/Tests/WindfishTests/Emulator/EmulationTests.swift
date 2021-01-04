import XCTest
@testable import Windfish

class InstructionEmulatorTests: XCTestCase {
  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 61 specs to go.
  static override func tearDown() {
    let remainingSpecs = LR35902.InstructionSet.allSpecs().filter { !testedSpecs.contains($0) }
    print("\(remainingSpecs.count) specs remaining to test")
  }
}

/**
 Note that each test includes a single nop instruction for padding at the end of the ROM due to how instructions are
 simultaneously executed and loaded in state.a single machine cycle.
 */
class EmulationTests: XCTestCase {
  private func createGameboy(loadedWith assembly: String) -> Gameboy {
    // Pad every test with state.a nop at the end so that the post-execution opcode fetch has something to fetch.
    let (instructions, errors) = RGBDSAssembler.assemble(assembly: assembly + "\n nop")
    precondition(errors.isEmpty, "Errors: \(errors)")
    let data = instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    return gameboy
  }

  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 265 specs to go.
  static override func tearDown() {
    let remainingSpecs = LR35902.InstructionSet.allSpecs().filter { !testedSpecs.contains($0) }
    print("\(remainingSpecs.count) specs remaining to test")
  }

  private func assertAdvance(gameboy: Gameboy, instruction: LR35902.Instruction,
                             setup: () -> Void,
                             expectedMutations: (inout LR35902) -> Void,
                             file: StaticString = #file, line: UInt = #line) {
    setup()

    var copiedCpu = gameboy.cpu.copy()
    gameboy.advanceInstruction()

    expectedMutations(&copiedCpu)

    assertEqual(gameboy.cpu, copiedCpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)",
                file: file, line: line)
  }

  // Verify that push / pop of the af register doesn't lose state along the way.
  func test_push_pop_af() throws {
    let gameboy = createGameboy(loadedWith: """
ld a, $ff
push af
pop af
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    gameboy.cpu.fcarry = true
    gameboy.cpu.fzero = true
    gameboy.cpu.fsubtract = true
    gameboy.cpu.fhalfcarry = true

    XCTAssertEqual(gameboy.cpu.a, 1)
    XCTAssertEqual(gameboy.cpu.sp, 0xFFFE)
    gameboy.advanceInstruction()
    XCTAssertEqual(gameboy.cpu.a, 255)
    gameboy.advanceInstruction()
    XCTAssertEqual(gameboy.cpu.sp, 0xFFFC)

    // Forcefully clear the flags
    gameboy.cpu.a = 0
    gameboy.cpu.fcarry = false
    gameboy.cpu.fzero = false
    gameboy.cpu.fsubtract = false
    gameboy.cpu.fhalfcarry = false

    // Pop
    gameboy.advanceInstruction()

    XCTAssertEqual(gameboy.cpu.a, 255)
    XCTAssertTrue(gameboy.cpu.fcarry)
    XCTAssertTrue(gameboy.cpu.fzero)
    XCTAssertTrue(gameboy.cpu.fsubtract)
    XCTAssertTrue(gameboy.cpu.fhalfcarry)
    XCTAssertEqual(gameboy.cpu.sp, 0xFFFE)
  }

  func test_00_nop() {
    // Given
    let gameboy = createGameboy(loadedWith: """
nop
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    assertAdvance(gameboy: gameboy, instruction: .init(spec: .nop)) {
      // No setup.
    } expectedMutations: { state in
      state.pc += 2
    }

    XCTAssertEqual(gameboy.cpu.machineInstruction.cycle, 0)
    XCTAssertEqual(testMemory.reads, [0x0000, 0x0001])
    XCTAssertEqual(testMemory.writes, [])
    XCTAssertEqual(gameboy.cpu.registerTraces, [:])
  }

  func test_ld_r_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
          // Set dst first in case dst == src
          gameboy.cpu[dst] = UInt8(0x00)
          gameboy.cpu[src] = UInt8(0xab)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        switch instruction.spec {
        case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
          state[dst] = UInt8(0xab)
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_r_n() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, .imm8) where registers8.contains(dst):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0x12)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(let dst, .imm8) where registers8.contains(dst):
          gameboy.cpu[dst] = UInt8(0x00)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2

        switch instruction.spec {
        case .ld(let dst, .imm8) where registers8.contains(dst):
          state[dst] = UInt8(0x12)
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_r_rraddr() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registersAddr = LR35902.Instruction.Numeric.registersAddr
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0x12, to: gameboy.cpu.hl)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
          gameboy.cpu[dst] = UInt8(0x00)
          gameboy.cpu[src] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1

        switch instruction.spec {
        case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
          state[dst] = UInt8(0x12)
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).reduce(into: [], { acc, addr in
      acc.append(addr)
      if addr < specs.count {
        acc.append(0xFF80)
      }
    }))
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_rraddr_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registersAddr = LR35902.Instruction.Numeric.registersAddr
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
          gameboy.cpu[src] = UInt8(0x12)
          gameboy.cpu[dst] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        switch instruction.spec {
        case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
          testMemory.ignoreWrites = true
          gameboy.memory.write(state[src], to: state[dst])
          testMemory.ignoreWrites = false
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, specs.map {
      switch $0 {
      case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
        if src == .h && dst == .hladdr {
          return .init(byte: 0xff, address: 0xFF80)
        } else if src == .l && dst == .hladdr {
          return .init(byte: 0x80, address: 0xFF80)
        } else {
          return .init(byte: 0x12, address: 0xFF80)
        }
      default:
        fatalError()
      }
    })
  }

  func test_ld_rraddr_n() throws {
    // Given
    let registersAddr = LR35902.Instruction.Numeric.registersAddr
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, .imm8) where registersAddr.contains(dst):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0x12)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(let dst, .imm8) where registersAddr.contains(dst):
          gameboy.cpu[dst] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2

        switch instruction.spec {
        case .ld(let dst, .imm8) where registersAddr.contains(dst):
          testMemory.ignoreWrites = true
          gameboy.memory.write(0x12, to: gameboy.cpu[dst])
          testMemory.ignoreWrites = false
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, specs.map { _ in
      return .init(byte: 0x12, address: 0xFF80)
    })
  }

  func test_ld_a_nnaddr() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.a, .imm16addr):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .ld(.a, .imm16addr):
          gameboy.cpu.a = UInt8(0x00)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 3

        switch instruction.spec {
        case .ld(.a, .imm16addr):
          state.a = UInt8(0xFA)  // opcode for this instruction
        default:
          fatalError()
        }
      }
    }

    XCTAssertEqual(testMemory.reads, [0, 1, 2, 0, 3])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_nnaddr_a() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.imm16addr, .a):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0xC000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(.imm16addr, .a):
        gameboy.cpu.a = UInt8(0x12)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 3

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1, 2, 3])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xC000)])
  }

  func test_ld_a_ffccadr() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.a, .ffccaddr):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.c = UInt8(0xab)
    gameboy.memory.write(0x12, to: 0xFFAB)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(.a, .ffccaddr):
        gameboy.cpu.a = UInt8(0x00)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      switch instruction.spec {
      case .ld(.a, .ffccaddr):
        state.a = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 0xffab, 1])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_ffccadr_a() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.ffccaddr, .a):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.c = UInt8(0xab)
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xFFAB)])
  }

  func test_ld_a_ffimm8addr() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.a, .ffimm8addr):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xab)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.memory.write(0x12, to: 0xFFAB)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(.a, .ffimm8addr):
        gameboy.cpu.a = UInt8(0x00)
      default:
        fatalError()
      }
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 2
      switch instruction.spec {
      case .ld(.a, .ffimm8addr):
        state.a = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1, 0xffab, 2])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_ffimm8addr_a() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.ffimm8addr, .a):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xab)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 2

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1, 2])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xFFAB)])
  }

  func test_ldd_a_hladdr() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ldd(.a, .hladdr):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0x12, to: 0xFF80)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ldd(.a, .hladdr):
        gameboy.cpu.a = UInt8(0x00)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      switch instruction.spec {
      case .ldd(.a, .hladdr):
        state.a = UInt8(0x12)
        state.hl -= 1
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 0xFF80, 1])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ldd_hladdr_a() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ldd(.hladdr, .a):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.hl -= 1

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xFF80)])
  }

  func test_ldi_a_hladdr() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ldi(.a, .hladdr):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0x12, to: 0xFF80)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ldi(.a, .hladdr):
        gameboy.cpu.a = UInt8(0x00)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      switch instruction.spec {
      case .ldi(.a, .hladdr):
        state.a = UInt8(0x12)
        state.hl += 1
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 0xFF80, 1])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ldi_hladdr_a() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ldi(.hladdr, .a):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.hl += 1

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [0, 1])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xFF80)])
  }

  func test_ld_rr_nn() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, .imm16) where registers16.contains(dst):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x1234)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, .imm16) where registers16.contains(dst):
        gameboy.cpu[dst] = UInt16(0x0000)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 3

      switch instruction.spec {
      case .ld(let dst, .imm16) where registers16.contains(dst):
        state[dst] = UInt16(0x1234)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_imm16add_sp() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.imm16addr, .sp):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0xFF80)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.sp = 0x1234
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 3

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [
      .init(byte: 0x34, address: 0xFF80),
      .init(byte: 0x12, address: 0xFF81),
    ])
  }

  func test_ld_sp_hl() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(.sp, .hl):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0x1234
    gameboy.cpu.sp = 0
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.sp = 0x1234

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_push_rr() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .push(let src) where registers16.contains(src):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.sp = 0xFFFD
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .push(let src) where registers16.contains(src):
        gameboy.cpu[src] = UInt16(0x1234)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.sp -= 2

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    var sp = UInt16(0xFFFD)
    XCTAssertEqual(testMemory.writes, specs.reduce(into: [], { accumulator, spec in
      if case .push(.af) = spec {
        accumulator.append(contentsOf: [
          .init(byte: 0x12, address: sp - 1),
          .init(byte: 0x30, address: sp - 2),  // Lower bits bits of f can never be set
        ])
      } else {
        accumulator.append(contentsOf: [
          .init(byte: 0x12, address: sp - 1),
          .init(byte: 0x34, address: sp - 2),
        ])
      }
      sp -= 2
    }))
  }

  func test_pop_rr() {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .pop(let dst) where registers16.contains(dst):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.sp = 0xFFE0
    var sp = gameboy.cpu.sp
    specs.forEach { _ in
      gameboy.memory.write(0x34, to: sp)
      gameboy.memory.write(0x12, to: sp + 1)
      sp += 2
    }
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .pop(let dst) where registers16.contains(dst):
        gameboy.cpu[dst] = UInt16(0x0000)
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.sp += 2
      switch instruction.spec {
      case .pop(let dst) where registers16.contains(dst):
        state[dst] = UInt16(0x1234)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    XCTAssertEqual(testMemory.reads, [
      0, 0xFFE0, 0xFFE1,
      1, 0xFFE2, 0xFFE3,
      2, 0xFFE4, 0xFFE5,
      3, 0xFFE6, 0xFFE7,
      4
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_jp_nn_all_true() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .jp(_, .imm16):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: "nop\n" + assembly)
    gameboy.cpu.pc = 1  // Skip the nop

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc
      switch instruction.spec {
      case .jp(let cnd, .imm16):
        switch cnd {
        case .none:
          break
        case .some(.c):
          gameboy.cpu.fcarry = true
          break
        case .some(.nz):
          gameboy.cpu.fzero = false
          break
        case .some(.z):
          gameboy.cpu.fzero = true
          break
        case .some(.nc):
          gameboy.cpu.fcarry = false
          break
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc = 0x0001

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 3
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      1, 2, 3, 0,
      4, 5, 6, 0,
      7, 8, 9, 0,
      10, 11, 12, 0,
      13, 14, 15, 0,
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_jp_nn_all_false() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .jp(let cnd, .imm16) where cnd != nil:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .jp(let cnd, .imm16) where cnd != nil:
        switch cnd {
        case .some(.c):
          gameboy.cpu.fcarry = false
          break
        case .some(.nz):
          gameboy.cpu.fzero = true
          break
        case .some(.z):
          gameboy.cpu.fzero = false
          break
        case .some(.nc):
          gameboy.cpu.fcarry = true
          break
        default:
          fatalError()
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 3

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_jp_hl() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .jp(nil, .hl):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly + "\n nop\n nop")
    gameboy.cpu.hl = 0x0002
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc = 0x0003

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [0, 2])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_jr_n_all_true() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .jr(_, .simm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(UInt8(bitPattern: 1))) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly + "\n nop\n nop")

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc
      switch instruction.spec {
      case .jr(let cnd, .simm8):
        switch cnd {
        case .none:
          break
        case .some(.c):
          gameboy.cpu.fcarry = true
          break
        case .some(.nz):
          gameboy.cpu.fzero = false
          break
        case .some(.z):
          gameboy.cpu.fzero = true
          break
        case .some(.nc):
          gameboy.cpu.fcarry = false
          break
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc += 2 + 1 + 1  // 2 for instruction, 1 for relative jump, 1 for next opcode read

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 2
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      0, 1, 3,
      2, 3, 5,
      4, 5, 7,
      6, 7, 9,
      8, 9, 11
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_jr_n_all_false() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .jr(let cnd, .simm8) where cnd != nil:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(UInt8(bitPattern: 1))) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .jr(let cnd, .simm8) where cnd != nil:
        switch cnd {
        case .some(.c):
          gameboy.cpu.fcarry = false
          break
        case .some(.nz):
          gameboy.cpu.fzero = true
          break
        case .some(.z):
          gameboy.cpu.fzero = false
          break
        case .some(.nc):
          gameboy.cpu.fcarry = true
          break
        default:
          fatalError()
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 2

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_call_nn_all_true() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .call(_, .imm16):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: "nop\n" + assembly)
    gameboy.cpu.sp = 0xFFFD
    gameboy.cpu.pc = 1  // Skip the nop

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc
      switch instruction.spec {
      case .call(let cnd, .imm16):
        switch cnd {
        case .none:
          break
        case .some(.c):
          gameboy.cpu.fcarry = true
          break
        case .some(.nz):
          gameboy.cpu.fzero = false
          break
        case .some(.z):
          gameboy.cpu.fzero = true
          break
        case .some(.nc):
          gameboy.cpu.fcarry = false
          break
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc = 0x0001
      state.sp -= 2

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 3
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      1, 2, 3, 0,
      4, 5, 6, 0,
      7, 8, 9, 0,
      10, 11, 12, 0,
      13, 14, 15, 0,
    ])
    XCTAssertEqual(testMemory.writes, [
      .init(byte: 0, address: UInt16(0xFFFD) - 1),
      .init(byte: 4, address: UInt16(0xFFFD) - 2),
      .init(byte: 0, address: UInt16(0xFFFD) - 3),
      .init(byte: 7, address: UInt16(0xFFFD) - 4),
      .init(byte: 0, address: UInt16(0xFFFD) - 5),
      .init(byte: 10, address: UInt16(0xFFFD) - 6),
      .init(byte: 0, address: UInt16(0xFFFD) - 7),
      .init(byte: 13, address: UInt16(0xFFFD) - 8),
      .init(byte: 0, address: UInt16(0xFFFD) - 9),
      .init(byte: 16, address: UInt16(0xFFFD) - 10),
    ])
  }

  func test_call_nn_all_false() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .call(let cnd, .imm16) where cnd != nil:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .call(let cnd, .imm16):
        switch cnd {
        case .some(.c):
          gameboy.cpu.fcarry = false
          break
        case .some(.nz):
          gameboy.cpu.fzero = true
          break
        case .some(.z):
          gameboy.cpu.fzero = false
          break
        case .some(.nc):
          gameboy.cpu.fcarry = true
          break
        default:
          fatalError()
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 3

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ret_all_true() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ret(_):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: "nop\n nop\n" + assembly)
    gameboy.cpu.sp = 0xFFE0
    var sp = gameboy.cpu.sp
    specs.forEach { _ in
      gameboy.memory.write(0x01, to: sp)
      gameboy.memory.write(0x00, to: sp + 1)
      sp += 2
    }
    gameboy.cpu.pc = 2

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc
      switch instruction.spec {
      case .ret(let cnd):
        switch cnd {
        case .none:
          break
        case .some(.c):
          gameboy.cpu.fcarry = true
          break
        case .some(.nz):
          gameboy.cpu.fzero = false
          break
        case .some(.z):
          gameboy.cpu.fzero = true
          break
        case .some(.nc):
          gameboy.cpu.fcarry = false
          break
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc = 1 + 1  // return to 1 and then +1 for opcode
      state.sp += 2

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      2, LR35902.Address(0xFFE0),     LR35902.Address(0xFFE0) + 1, 1,
      3, LR35902.Address(0xFFE0) + 2, LR35902.Address(0xFFE0) + 3, 1,
      4, LR35902.Address(0xFFE0) + 4, LR35902.Address(0xFFE0) + 5, 1,
      5, LR35902.Address(0xFFE0) + 6, LR35902.Address(0xFFE0) + 7, 1,
      6, LR35902.Address(0xFFE0) + 8, LR35902.Address(0xFFE0) + 9, 1,
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ret_all_false() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ret(let cnd) where cnd != nil:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ret(let cnd):
        switch cnd {
        case .none:
          break
        case .some(.c):
          gameboy.cpu.fcarry = false
          break
        case .some(.nz):
          gameboy.cpu.fzero = true
          break
        case .some(.z):
          gameboy.cpu.fzero = false
          break
        case .some(.nc):
          gameboy.cpu.fcarry = true
          break
        }
        break
      default:
        fatalError()
      }

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_reti() {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .reti:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: "nop\n nop\n" + assembly)
    gameboy.cpu.sp = 0xFFE0
    var sp = gameboy.cpu.sp
    specs.forEach { _ in
      gameboy.memory.write(0x01, to: sp)
      gameboy.memory.write(0x00, to: sp + 1)
      sp += 2
    }
    gameboy.cpu.pc = 2

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      state.pc = 1 + 1  // return to 1 and then +1 for opcode
      state.sp += 2
      state.ime = true

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      2, LR35902.Address(0xFFE0),     LR35902.Address(0xFFE0) + 1, 1,
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_res() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cb(.res(_, let register)) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    let expectedResults: [LR35902.Instruction.Bit: UInt8] = [
      .b0: 0b1111_1110,
      .b1: 0b1111_1101,
      .b2: 0b1111_1011,
      .b3: 0b1111_0111,
      .b4: 0b1110_1111,
      .b5: 0b1101_1111,
      .b6: 0b1011_1111,
      .b7: 0b0111_1111,
    ]

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .cb(.res(_, let register)) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(0xFF)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2

        switch instruction.spec {
        case .cb(.res(let bit, let register)) where registers8.contains(register):
          state[register] = expectedResults[bit]!
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_imm8_equal() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(16)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 16
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = true
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_imm8_less() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(16)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 15
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = true
        state.fhalfcarry = false
        state.fzero = false
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_imm8_greater() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(16)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 17
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = false
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_imm8_halfcarry() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0b0000_0010)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0b0000_0001
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = true
        state.fhalfcarry = true
        state.fzero = false
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_r_equal() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(let register) where registers8.contains(register): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 16
        switch instruction.spec {
        case .cp(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(16)
        default: fatalError()
        }
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = true
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_r_less() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(let register) where registers8.contains(register): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 15
        switch instruction.spec {
        case .cp(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(16)
        default: fatalError()
        }
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = true
        state.fhalfcarry = false

        switch instruction.spec {
        case .cp(.a):
          state.fcarry = false
          state.fzero = true
        default:
          state.fcarry = true
          state.fzero = false
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_cp_r_greater() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .cp(let register) where registers8.contains(register): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 17
        switch instruction.spec {
        case .cp(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(16)
        default: fatalError()
        }
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = true
        state.fhalfcarry = false

        switch instruction.spec {
        case .cp(.a):
          state.fcarry = false
          state.fzero = true
        default:
          state.fcarry = false
          state.fzero = false
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_inc_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .inc(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(1)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = false
      state.fzero = false
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        state[register] = UInt8(2)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_inc_r_overflow() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .inc(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(255)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = false
      gameboy.cpu.fzero = false

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = true
      state.fzero = true
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        state[register] = UInt8(0)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_inc_r_halfcarry() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .inc(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0x0F)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = false
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = true
      state.fzero = false
      switch instruction.spec {
      case .inc(let register) where registers8.contains(register):
        state[register] = UInt8(0x10)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_dec_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .dec(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(255)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = false
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = true
      state.fcarry = false
      state.fhalfcarry = false
      state.fzero = false
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        state[register] = UInt8(254)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_dec_r_zero() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .dec(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(1)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = false
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = false

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = true
      state.fcarry = false
      state.fhalfcarry = false
      state.fzero = true
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        state[register] = UInt8(0)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_dec_r_underflow() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .dec(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = false
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = false
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = true
      state.fcarry = false
      state.fhalfcarry = true
      state.fzero = false
      switch instruction.spec {
      case .dec(let register) where registers8.contains(register):
        state[register] = UInt8(255)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_dec_rr() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .dec(let register) where registers16.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .dec(let register) where registers16.contains(register):
          gameboy.cpu[register] = UInt16(255)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        switch instruction.spec {
        case .dec(let register) where registers16.contains(register):
          state[register] = UInt16(254)
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_dec_rr_underflow() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .dec(let register) where registers16.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        switch instruction.spec {
        case .dec(let register) where registers16.contains(register):
          gameboy.cpu[register] = UInt16(0)
        default:
          fatalError()
        }
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        switch instruction.spec {
        case .dec(let register) where registers16.contains(register):
          state[register] = UInt16(0xffff)
        default:
          fatalError()
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_di() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .di:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      gameboy.cpu.ime = true
      gameboy.cpu.imeScheduledCyclesRemaining = 2

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.ime = false
      state.imeScheduledCyclesRemaining = 0

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ei() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .ei:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly + "\n nop")

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      gameboy.cpu.ime = false
      gameboy.cpu.imeScheduledCyclesRemaining = 0

      var state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      gameboy.cpu.ime = false  // Not enabled immediately.
      gameboy.cpu.imeScheduledCyclesRemaining = 1

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      state = gameboy.cpu.copy()
      gameboy.advance()

      // Expected mutations
      state.pc += 1
      state.ime = true

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ei_di() throws {
    // Given
    let gameboy = createGameboy(loadedWith: "ei\n di\n nop")

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    gameboy.cpu.ime = false
    gameboy.cpu.imeScheduledCyclesRemaining = 0

    var state = gameboy.cpu.copy()
    gameboy.advanceInstruction()

    // Expected mutations
    state.pc += 2
    state.ime = false  // Not enabled immediately.
    state.imeScheduledCyclesRemaining = 1

    assertEqual(gameboy.cpu, state)

    state = gameboy.cpu.copy()
    gameboy.advance()

    // Expected mutations
    state.pc += 1
    state.ime = false
    state.imeScheduledCyclesRemaining = 0

    assertEqual(gameboy.cpu, state)
  }

  func test_inc_rr() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .inc(let register) where registers16.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .inc(let register) where registers16.contains(register):
        gameboy.cpu[register] = UInt16(1)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      switch instruction.spec {
      case .inc(let register) where registers16.contains(register):
        state[register] = UInt16(2)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_inc_rr_overflow() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .inc(let register) where registers16.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .inc(let register) where registers16.contains(register):
        gameboy.cpu[register] = UInt16(0xffff)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = false
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      switch instruction.spec {
      case .inc(let register) where registers16.contains(register):
        state[register] = UInt16(0)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_or_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .or(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      gameboy.cpu.a = 0b0000_0001
      switch instruction.spec {
      case .or(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0b0000_0010)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = true
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = false
      state.fzero = false
      switch instruction.spec {
      case .or(.a):
        break  // Nothing changed.
      default:
        state.a = 0b0000_0011
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_or_r_zero() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .or(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      gameboy.cpu.a = 0
      switch instruction.spec {
      case .or(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = true
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = false
      state.fzero = true

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_or_hladdr_zero() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .or(.hladdr): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0, to: gameboy.cpu.hl)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = true
        state.a = 0
      }
    }

    XCTAssertEqual(testMemory.reads, [
      0, 0xFF80,
      1
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_or_hladdr() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .or(.hladdr): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0b0000_0010, to: gameboy.cpu.hl)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0b0000_0001
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = false
        state.a = 0b0000_0011
      }
    }

    XCTAssertEqual(testMemory.reads, [
      0, 0xFF80,
      1
    ])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_and_imm8() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .and(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xFF)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0F
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        state.fzero = false
        state.a = 0x0f
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_and_imm8_zero() throws {
    // Given
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .and(.imm8):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xF0)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0F
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        state.fzero = true
        state.a = 0x00
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_and_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .and(let register) where registers8.contains(register): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0F
        switch instruction.spec {
        case .and(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(0xFF)
        default: fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        state.fzero = false
        switch instruction.spec {
        case .and(.a):
          state.a = 0xff
        default:
          state.a = 0x0f
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_and_r_zero() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .and(let register) where registers8.contains(register): return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0F
        switch instruction.spec {
        case .and(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(0xF0)
        default: fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        switch instruction.spec {
        case .and(.a):
          state.a = 0xf0
          state.fzero = false
        default:
          state.a = 0x00
          state.fzero = true
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_xor_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .xor(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      gameboy.cpu.a = 0b0000_0101
      switch instruction.spec {
      case .xor(let register) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0b0000_0110)
      default:
        fatalError()
      }
      gameboy.cpu.fsubtract = true
      gameboy.cpu.fcarry = true
      gameboy.cpu.fhalfcarry = true
      gameboy.cpu.fzero = true

      let state = gameboy.cpu.copy()
      gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        state.pc += 1
      }
      state.pc += 1
      state.fsubtract = false
      state.fcarry = false
      state.fhalfcarry = false
      switch instruction.spec {
      case .xor(.a):
        state.a = 0b0000_0000
        state.fzero = true
      default:
        state.a = 0b0000_0011
        state.fzero = false
      }

      assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_xor_r_zero() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .xor(let register) where registers8.contains(register):
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0f
        switch instruction.spec {
        case .xor(let register) where registers8.contains(register):
          gameboy.cpu[register] = UInt8(0x0f)
        default:
          fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = true
        state.a = 0
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_n() throws {
    // Given
    let addimm8 = LR35902.Instruction.Spec.add(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case addimm8:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = false
        state.a = 1
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_n_overflow() throws {
    // Given
    let addimm8 = LR35902.Instruction.Spec.add(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case addimm8:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 255
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = false
        state.fcarry = true
        state.fhalfcarry = true
        state.fzero = true
        state.a = 0
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_n_halfcarry() throws {
    // Given
    let addimm8 = LR35902.Instruction.Spec.add(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case addimm8:
        return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0x0f
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        state.fzero = false
        state.a = 0x10
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_sub_n() throws {
    // Given
    let subimm8 = LR35902.Instruction.Spec.sub(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case subimm8: return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 2
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = false
        state.a = 1
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_sub_n_underflow() throws {
    // Given
    let subimm8 = LR35902.Instruction.Spec.sub(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case subimm8: return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = true
        state.fhalfcarry = true
        state.fzero = false
        state.a = 255
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_sub_n_zero() throws {
    // Given
    let subimm8 = LR35902.Instruction.Spec.sub(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case subimm8: return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 1
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
        gameboy.cpu.fzero = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = false
        state.fzero = true
        state.a = 0
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_sub_n_halfcarry() throws {
    // Given
    let subimm8 = LR35902.Instruction.Spec.sub(.a, .imm8)
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case subimm8: return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.a = 0b1111_0000
        gameboy.cpu.fsubtract = false
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
        gameboy.cpu.fzero = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 2
        state.fsubtract = true
        state.fcarry = false
        state.fhalfcarry = true
        state.fzero = false
        state.a = 0b1110_1111
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_hl_rr() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .add(.hl, let src) where registers16.contains(src): return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.hl = 3
        switch instruction.spec {
        case .add(.hl, let src) where registers16.contains(src):
          gameboy.cpu[src] = UInt16(2)
        default:
          fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = true
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = false
        switch instruction.spec {
        case .add(.hl, .hl):
          state.hl = 4
        default:
          state.hl = 5
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_hl_rr_overflow() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .add(.hl, let src) where registers16.contains(src): return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.hl = 1
        switch instruction.spec {
        case .add(.hl, let src) where registers16.contains(src):
          gameboy.cpu[src] = UInt16(0xffff)
        default:
          fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = false
        gameboy.cpu.fhalfcarry = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = true
        state.fhalfcarry = true
        switch instruction.spec {
        case .add(.hl, .hl):
          state.hl = 0xfffe
        default:
          state.hl = 0
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_add_hl_rr_halfcarry() throws {
    // Given
    let registers16 = LR35902.Instruction.Numeric.registers16
    let specs = LR35902.InstructionSet.allSpecs().filter { spec in
      switch spec {
      case .add(.hl, let src) where registers16.contains(src): return true
      default:      return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(1)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      assertAdvance(gameboy: gameboy, instruction: instruction) {
        gameboy.cpu.hl = 1
        switch instruction.spec {
        case .add(.hl, let src) where registers16.contains(src):
          gameboy.cpu[src] = UInt16(0x0fff)
        default:
          fatalError()
        }
        gameboy.cpu.fsubtract = true
        gameboy.cpu.fcarry = true
        gameboy.cpu.fhalfcarry = false
      } expectedMutations: { state in
        if index == 0 {
          state.pc += 1
        }
        state.pc += 1
        state.fsubtract = false
        state.fcarry = false
        state.fhalfcarry = true
        switch instruction.spec {
        case .add(.hl, .hl):
          state.hl = 0x1ffe
        default:
          state.hl = 0x1000
        }
      }
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_halt() throws {
    // Given
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union([.halt])
    let instructions = [.halt].map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: assembly)

    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    let state = gameboy.cpu.copy()
    gameboy.advance()  // Load opcode
    gameboy.advance()  // Execute halt instruction
    gameboy.advance()  // Does nothing, verified by lack of read of next opcode.

    // Then
    state.pc += 1
    state.halted = true
    assertEqual(gameboy.cpu, state, message: "Spec: \(RGBDSDisassembler.statement(for: instructions[0]).formattedString)")

    XCTAssertEqual(testMemory.reads, [0])
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_rst_n() throws {
    // Given
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .rst: return true
      default: return false
      }
    }
    EmulationTests.testedSpecs = EmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    let gameboy = createGameboy(loadedWith: (0..<100).map { _ in "nop" }.joined(separator: "\n") + "\n" + assembly )
    gameboy.cpu.pc = 100
    gameboy.cpu.sp = 0xFFFD
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc

      assertAdvance(gameboy: gameboy, instruction: instruction) {
        // No setup.
      } expectedMutations: { state in
        state.sp -= 2

        switch instruction.spec {
        case .rst(let address):
          state.pc = UInt16(address.rawValue) + 1
        default: fatalError()
        }
      }

      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force state.a re-load
    }

    XCTAssertEqual(testMemory.reads, [
      100, 0,
      101, 8,
      102, 16,
      103, 24,
      104, 32,
      105, 40,
      106, 48,
      107, 56
    ])
    var pc = UInt8(101)
    var sp = UInt16(0xFFFD)
    XCTAssertEqual(testMemory.writes, specs.reduce(into: [], { accumulator, spec in
      accumulator.append(contentsOf: [
        .init(byte: 00, address: sp - 1),
        .init(byte: pc, address: sp - 2),
      ])
      pc += 1
      sp -= 2
    }))
  }

}
