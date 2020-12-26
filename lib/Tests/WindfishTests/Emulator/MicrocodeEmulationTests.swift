import XCTest
@testable import Windfish

/**
 Note that each test includes a single nop instruction for padding at the end of the ROM due to how instructions are
 simultaneously executed and loaded in a single machine cycle.
 */
class MicrocodeEmulationTests: XCTestCase {
  private func createGameboy(loadedWith assembly: String) -> Gameboy {
    let (instructions, errors) = RGBDSAssembler.assemble(assembly: assembly)
    precondition(errors.isEmpty, "Errors: \(errors)")
    let data = instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    return Gameboy(cartridge: .init(data: data))
  }

  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 335 specs to go.
  static override func tearDown() {
    let remainingSpecs = LR35902.InstructionSet.allSpecs().filter { !testedSpecs.contains($0) }
    print("\(remainingSpecs.count) specs remaining to test")
  }

  func test_00_nop() {
    // Given
    var gameboy = createGameboy(loadedWith: """
nop
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    let mutated = gameboy.advanceInstruction()

    // Expected mutations
    gameboy.cpu.pc += 2

    assertEqual(gameboy.cpu, mutated.cpu)
    XCTAssertEqual(mutated.cpu.machineInstruction.cycle, 0)
    XCTAssertEqual(testMemory.reads, [0x0000, 0x0001])
    XCTAssertEqual(testMemory.writes, [])
    XCTAssertEqual(mutated.cpu.registerTraces, [:])
  }

  func test_ld_r_r() throws {
    // Given
    let registers8 = LR35902.Instruction.Numeric.registers8
    let specs = LR35902.InstructionSet.table.filter { spec in
      switch spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        return true
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        // Set dst first in case dst == src
        gameboy.cpu[dst] = UInt8(0x00)
        gameboy.cpu[src] = UInt8(0xab)
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1

      switch instruction.spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        gameboy.cpu[dst] = UInt8(0xab)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0x12)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, .imm8) where registers8.contains(dst):
        gameboy.cpu[dst] = UInt8(0x00)
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2

      switch instruction.spec {
      case .ld(let dst, .imm8) where registers8.contains(dst):
        gameboy.cpu[dst] = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0xFF80
    gameboy.memory.write(0x12, to: gameboy.cpu.hl)
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
        gameboy.cpu[dst] = UInt8(0x00)
        gameboy.cpu[src] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1

      switch instruction.spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
        gameboy.cpu[dst] = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0xFF80
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
        gameboy.cpu[src] = UInt8(0x12)
        gameboy.cpu[dst] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1

      switch instruction.spec {
      case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
        testMemory.ignoreWrites = true
        gameboy.memory.write(gameboy.cpu[src], to: gameboy.cpu[dst])
        testMemory.ignoreWrites = false
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0x12)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0xFF80
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(let dst, .imm8) where registersAddr.contains(dst):
        gameboy.cpu[dst] = UInt16(0xFF80) // Always reset hl in case we're writing to h or l.
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2

      switch instruction.spec {
      case .ld(let dst, .imm8) where registersAddr.contains(dst):
        testMemory.ignoreWrites = true
        gameboy.memory.write(0x12, to: gameboy.cpu[dst])
        testMemory.ignoreWrites = false
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      switch instruction.spec {
      case .ld(.a, .imm16addr):
        gameboy.cpu.a = UInt8(0x00)
      default:
        fatalError()
      }
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      switch instruction.spec {
      case .ld(.a, .imm16addr):
        gameboy.cpu.a = UInt8(0xFA)  // opcode for this instruction
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0xC000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      switch instruction.spec {
      case .ld(.a, .ffccaddr):
        gameboy.cpu.a = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.c = UInt8(0xab)
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xab)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2
      switch instruction.spec {
      case .ld(.a, .ffimm8addr):
        gameboy.cpu.a = UInt8(0x12)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(0xab)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      switch instruction.spec {
      case .ldd(.a, .hladdr):
        gameboy.cpu.a = UInt8(0x12)
        gameboy.cpu.hl -= 1
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0xFF80
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      gameboy.cpu.hl -= 1

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      switch instruction.spec {
      case .ldi(.a, .hladdr):
        gameboy.cpu.a = UInt8(0x12)
        gameboy.cpu.hl += 1
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0xFF80
    gameboy.cpu.a = 0x12
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      gameboy.cpu.hl += 1

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x1234)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      switch instruction.spec {
      case .ld(let dst, .imm16) where registers16.contains(dst):
        gameboy.cpu[dst] = UInt16(0x1234)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0xFF80)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.sp = 0x1234
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
    gameboy.cpu.hl = 0x1234
    gameboy.cpu.sp = 0
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for (index, instruction) in instructions.enumerated() {
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      gameboy.cpu.sp = 0x1234

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      gameboy.cpu.sp -= 2

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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
      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1
      gameboy.cpu.sp += 2
      switch instruction.spec {
      case .pop(let dst) where registers16.contains(dst):
        gameboy.cpu[dst] = UInt16(0x1234)
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: "nop\n" + assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc = 0x0001

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 3
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop\n nop")
    gameboy.cpu.hl = 0x0002
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    for instruction in instructions {
      let stashedpc = gameboy.cpu.pc

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc = 0x0003

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(UInt8(bitPattern: 1))) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop\n nop")

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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc += 2 + 1 + 1  // 2 for instruction, 1 for relative jump, 1 for next opcode read

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 2
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm8(UInt8(bitPattern: 1))) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: "nop\n" + assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc = 0x0001
      gameboy.cpu.sp -= 2

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 3
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")

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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 3

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: "nop\n nop\n" + assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc = 1 + 1  // return to 1 and then +1 for opcode
      gameboy.cpu.sp += 2

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")

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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 1

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: "nop\n nop\n" + assembly + "\n nop")
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

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      gameboy.cpu.pc = 1 + 1  // return to 1 and then +1 for opcode
      gameboy.cpu.sp += 2
      gameboy.cpu.ime = true

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
      gameboy.cpu.pc = stashedpc + 1
      gameboy.cpu.machineInstruction = .init() // Reset the cpu's machine instruction cache to force a re-load
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
      default:
        return false
      }
    }
    MicrocodeEmulationTests.testedSpecs = MicrocodeEmulationTests.testedSpecs.union(specs)
    let instructions = specs.map { LR35902.Instruction(spec: $0, immediate: .imm16(0x0000)) }
    let assembly = instructions.map { RGBDSDisassembler.statement(for: $0).formattedString }.joined(separator: "\n")
    var gameboy = createGameboy(loadedWith: assembly + "\n nop")

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
      switch instruction.spec {
      case .cb(.res(_, let register)) where registers8.contains(register):
        gameboy.cpu[register] = UInt8(0xFF)
      default:
        fatalError()
      }

      let mutated = gameboy.advanceInstruction()

      // Expected mutations
      if index == 0 {
        gameboy.cpu.pc += 1
      }
      gameboy.cpu.pc += 2

      switch instruction.spec {
      case .cb(.res(let bit, let register)) where registers8.contains(register):
        gameboy.cpu[register] = expectedResults[bit]!
      default:
        fatalError()
      }

      assertEqual(gameboy.cpu, mutated.cpu, message: "Spec: \(RGBDSDisassembler.statement(for: instruction).formattedString)")

      gameboy = mutated
    }

    let cartridge = try XCTUnwrap(gameboy.cartridge)
    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

}
