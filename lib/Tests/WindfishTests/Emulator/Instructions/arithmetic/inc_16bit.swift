import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt16
    struct Result {
      let value: UInt16
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "overflow":  .init(value: 0xffff, result: .init(value: 0)),
      "positive":  .init(value: 0,      result: .init(value: 1)),
      "lowtohigh": .init(value: 0xff,   result: .init(value: 0x0100)),
    ]
  }

  func test_inc_rr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .inc(let register) = spec,
              let emulator = LR35902.Emulation.inc_rr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
