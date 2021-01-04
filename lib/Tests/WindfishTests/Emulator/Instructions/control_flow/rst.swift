import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    struct Result {
      let pc: [LR35902.Instruction.RestartAddress: UInt16]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "rst": .init(result: .init(pc: [.x00: 0x00, .x08: 0x08, .x10: 0x10, .x18: 0x18, .x20: 0x20, .x28: 0x28, .x30: 0x30, .x38: 0x38])),
    ]
  }

  func test_rst_n() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .rst(let address) = spec,
              let emulator = LR35902.Emulation.rst_n(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = 2
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 4, "Test case: \(name)")
        mutations.pc = testCase.result.pc[address]!
        mutations.sp = 0
        assertEqual(cpu, mutations, message: "Test case: \(name)")
        XCTAssertEqual(memory.reads, [], "Test case: \(name)")
        XCTAssertEqual(memory.writes, [
          .init(byte: 0x00, address: 1),
          .init(byte: 0x00, address: 0),
        ], "Test case: \(name)")
      }
    }
  }
}
