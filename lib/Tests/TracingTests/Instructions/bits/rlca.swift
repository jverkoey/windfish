import XCTest

import LR35902
@testable import Tracing

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fc: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(value: 0,           result: .init(fc: false, value: 0)),
      "0000_0001":  .init(value: 0b0000_0001, result: .init(fc: false, value: 0b0000_0010)),
      "0000_1000":  .init(value: 0b0000_1000, result: .init(fc: false, value: 0b0001_0000)),
      "1000_0000":  .init(value: 0b1000_0000, result: .init(fc: true,  value: 0b0000_0001)),
    ]
  }

  func test_rlca() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.rlca(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.value
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = true
        cpu.fcarry = !testCase.result.fc
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fcarry = testCase.result.fc
        mutations.fzero = false
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.a = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
