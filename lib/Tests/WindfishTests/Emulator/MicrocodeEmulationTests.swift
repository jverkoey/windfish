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
