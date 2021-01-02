import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ld_r_r() {

    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, let src) = spec,
            let emulator = LR35902.Emulation.ld_r_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu[src] = UInt8(0x01)
      cpu[dst] = UInt8(0x10)

      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 1)
      mutations[dst] = mutations[src] as UInt8
      assertEqual(cpu, mutations)
    }
  }
}
