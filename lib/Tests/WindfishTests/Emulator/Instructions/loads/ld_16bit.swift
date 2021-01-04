import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ld_rr_nn() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, .imm16) = spec, let emulator = LR35902.Emulation.ld_rr_nn(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 3)
      mutations.pc += 2
      mutations[dst] = 0x1212 as UInt16
      assertEqual(cpu, mutations)
    }
  }
}
