import XCTest
@testable import Windfish

class MicrocodeEmulationTests: XCTestCase {
  private func createGameboy(loadedWith assembly: String) -> Gameboy {
    let data = RGBDSAssembler.assemble(assembly: assembly).instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    return Gameboy(cartridge: .init(data: data))
  }

  func test_00_nop() {
    // Given
    var gameboy = createGameboy(loadedWith: """
nop
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    let mutated = gameboy.advance()

    // Expected mutations
    gameboy.cpu.pc += 1

    assertEqual(gameboy.cpu, mutated.cpu)
    XCTAssertEqual(testMemory.reads, [0x0000])
    XCTAssertEqual(testMemory.writes, [])
    XCTAssertEqual(mutated.cpu.registerTraces, [:])
  }

  func test_01_ld_bc_imm16() {
    // Given
    var gameboy = createGameboy(loadedWith: """
ld bc, $abcd
""")
    let testMemory = TestMemory()
    gameboy.addMemoryTracer(testMemory)

    // When
    let mutated = gameboy.advance().advance().advance().advance()

    // Expected mutations
    gameboy.cpu.b = 0xab
    gameboy.cpu.c = 0xcd
    gameboy.cpu.pc += 3

    assertEqual(gameboy.cpu, mutated.cpu)
    XCTAssertEqual(testMemory.reads, [0x0000, 0x0001, 0x0002])
    XCTAssertEqual(testMemory.writes, [])
    XCTAssertEqual(mutated.cpu.registerTraces, [
      .bc: .init(sourceLocation: 0x0000, loadAddress: 0xabcd)
    ])
  }
}
