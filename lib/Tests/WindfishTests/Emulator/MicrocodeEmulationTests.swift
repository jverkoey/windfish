import XCTest
@testable import Windfish

/**
 Note that each test includes a single nop instruction for padding at the end of the ROM due to how instructions are
 simultaneously executed and loaded in a single machine cycle.
 */
class MicrocodeEmulationTests: XCTestCase {
  private func createGameboy(loadedWith assembly: String) -> Gameboy {
    let data = RGBDSAssembler.assemble(assembly: assembly).instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    return Gameboy(cartridge: .init(data: data))
  }

  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 456 specs to go.
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

  func test_01_ld_bc_imm16() {
    // Given
    var gameboy = createGameboy(loadedWith: """
ld bc, $abcd
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    let mutated = gameboy.advanceInstruction()

    // Expected mutations
    gameboy.cpu.bc = 0xabcd
    gameboy.cpu.pc += 4

    assertEqual(gameboy.cpu, mutated.cpu)
    XCTAssertEqual(testMemory.reads, [0x0000, 0x0001, 0x0002, 0x0003])
    XCTAssertEqual(testMemory.writes, [])
    XCTAssertEqual(mutated.cpu.registerTraces, [
      .bc: .init(sourceLocation: 0x0000, loadAddress: 0xabcd)
    ])
  }

  func test_02_ld_bcaddr_a() {
    // Given
    var gameboy = createGameboy(loadedWith: """
ld [bc], a
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    gameboy.cpu.a = 0x12
    gameboy.cpu.bc = 0xFF80
    let mutated = gameboy.advanceInstruction()

    // Expected mutations
    gameboy.cpu.pc += 2

    assertEqual(gameboy.cpu, mutated.cpu)
    XCTAssertEqual(testMemory.reads, [0x0000, 0x0001])
    XCTAssertEqual(testMemory.writes, [.init(byte: 0x12, address: 0xFF80)])
    XCTAssertEqual(mutated.cpu.registerTraces, [:])
  }
}
