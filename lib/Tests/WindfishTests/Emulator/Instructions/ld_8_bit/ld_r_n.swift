import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ld_r_n() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_r_n(spec: spec) else { continue }
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 2)
      guard case .ld(let dst, .imm8) = spec else {
        XCTFail()
        continue
      }
      mutations.pc += 1
      mutations[dst] = 0x12 as UInt8
      assertEqual(cpu, mutations)
    }
  }
}
