import XCTest
@testable import Windfish

class InstructionCBEmulationTests: XCTestCase {
  func test_87_res_b0_a_zero() {
    var cpu = LR35902(a: 0)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.prefixTables[LR35902.InstructionSet.table[0xCB]]![0x87]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.a = 0b0000_0000
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_87_res_b0_a_all() {
    var cpu = LR35902(a: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.prefixTables[LR35902.InstructionSet.table[0xCB]]![0x87]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.a = 0b1111_1110
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }
}
