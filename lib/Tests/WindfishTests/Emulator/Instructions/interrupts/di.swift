import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_di() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.di(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()

      let mutations = cpu.copy()
      mutations.ime = false
      mutations.imeScheduledCyclesRemaining = 0

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 1)
      assertEqual(cpu, mutations)
    }
  }
}
