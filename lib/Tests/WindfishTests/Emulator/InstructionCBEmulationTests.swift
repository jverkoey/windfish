import XCTest
@testable import Windfish

class InstructionCBEmulationTests: XCTestCase {
  func test_87_res_b0_a_zero() {
    let cpu = LR35902(a: 0)
    var state = cpu.state
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.prefixTables[LR35902.InstructionSet.table[0xCB]]![0x87]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.a = 0b0000_0000
    state.pc += 2

    assertEqual(state, cpu.state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.state.registerTraces, [:])
  }

  func test_87_res_b0_a_all() {
    let cpu = LR35902(a: 0xff)
    var state = cpu.state
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.prefixTables[LR35902.InstructionSet.table[0xCB]]![0x87]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.a = 0b1111_1110
    state.pc += 2

    assertEqual(state, cpu.state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.state.registerTraces, [:])
  }
}
