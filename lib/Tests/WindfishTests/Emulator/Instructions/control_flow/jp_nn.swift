import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_jp_nn() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .jp(let cnd, .imm16) = spec, cnd == nil,
            let emulator = LR35902.Emulation.jp_cnd_nn(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 4, "Test case: \(name)")
      mutations.pc = 0x1212
      assertEqual(cpu, mutations, message: "Test case: \(name)")
    }
  }
}
