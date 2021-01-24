import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ei() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ei(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()

      let mutations = cpu.copy()
      mutations.imeToggleDelay = 2
emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations)
    }
  }
}
