import XCTest
@testable import Windfish

/**
 Note that each test includes a single nop instruction for padding at the end of the ROM due to how instructions are
 simultaneously executed and loaded in a single machine cycle.
 */
class MicrocodeEmulationTests: XCTestCase {
  private func createGameboy(loadedWith assembly: String) -> Gameboy {
    let (instructions, errors) = RGBDSAssembler.assemble(assembly: assembly)
    XCTAssertEqual(errors, [])
    let data = instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    return Gameboy(cartridge: .init(data: data))
  }

  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 434 specs to go.
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

  func test_ld_r_r() {
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

    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(gameboy.cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_r_n() {
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

    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(gameboy.cartridge.size)).map { $0 })
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_r_rraddr() {
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

    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(gameboy.cartridge.size)).reduce(into: [], { acc, addr in
      acc.append(addr)
      if addr < specs.count {
        acc.append(0xFF80)
      }
    }))
    XCTAssertEqual(testMemory.writes, [])
  }

  func test_ld_rraddr_r() {
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

    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(gameboy.cartridge.size)).map { $0 })
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

  func test_ld_rraddr_n() {
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

    XCTAssertEqual(testMemory.reads, (LR35902.Address(0)..<LR35902.Address(gameboy.cartridge.size)).map { $0 })
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

}
