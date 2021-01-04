import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_pop() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .pop(let register) = spec, let emulator = LR35902.Emulation.pop_rr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.sp = 0xfffc
      let mutations = cpu.copy()
      mutations.sp = 0xfffe
      mutations[register] = 0x1212 as UInt16

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
      XCTAssertEqual(cycle, 3)
      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [0xfffc, 0xfffd], "\(spec)")
      XCTAssertEqual(memory.writes, [], "\(spec)")
    }
  }
}
