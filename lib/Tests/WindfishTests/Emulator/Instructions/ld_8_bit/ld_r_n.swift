import XCTest
@testable import Windfish

class ld_r_nTests: XCTestCase {
  func testTimingsAndCorrectness() {
    let defaultMemoryValue: UInt8 = 0x12
    let memory = TestMemory(defaultReadValue: defaultMemoryValue)

    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_r_n(spec: spec) else {
        continue
      }

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
      mutations[dst] = defaultMemoryValue
      assertEqual(cpu, mutations)
    }
  }
}
