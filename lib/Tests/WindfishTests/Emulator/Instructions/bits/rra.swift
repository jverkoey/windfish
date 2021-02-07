import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    let fc: Bool
    struct Result {
      let fc: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(value: 0,           fc: false, result: .init(fc: false, value: 0)),
      "0000_0001":  .init(value: 0b0000_0001, fc: false, result: .init(fc: true,  value: 0)),
      "0001_0000":  .init(value: 0b0001_0000, fc: false, result: .init(fc: false, value: 0b0000_1000)),
      "1000_0000":  .init(value: 0b1000_0000, fc: false, result: .init(fc: false, value: 0b0100_0000)),

      "c0000_0000": .init(value: 0,           fc: true, result: .init(fc: false, value: 0b1000_0000)),
      "c0000_0001": .init(value: 0b0000_0001, fc: true, result: .init(fc: true,  value: 0b1000_0000)),
      "c0001_0000": .init(value: 0b0001_0000, fc: true, result: .init(fc: false, value: 0b1000_1000)),
      "c1000_0000": .init(value: 0b1000_0000, fc: true, result: .init(fc: false, value: 0b1100_0000)),
    ]
  }

  func test_rra() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.rra(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.value
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = true
        cpu.fcarry = testCase.fc
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
