import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_call_nn() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .call(let cnd, .imm16) = spec, cnd == nil,
            let emulator = LR35902.Emulation.call_cnd_nn(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.sp = 0x100
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 6)
      mutations.pc = 0x1212
      mutations.sp = 0x100 - 2
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1])
      XCTAssertEqual(memory.writes, [
        .init(byte: 0, address: 0xff),
        .init(byte: 2, address: 0xfe),
      ])
    }
  }
}