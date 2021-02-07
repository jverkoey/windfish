import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let addr: Int8
    struct Result {
      let pc: UInt16
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "positive": .init(addr: 2,  result: .init(pc: 4)),
      "negative": .init(addr: -2, result: .init(pc: 0)),
    ]
  }

  func test_jr_nn() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .jr(let cnd, .imm16) = spec, cnd == nil,
              let emulator = LR35902.Emulation.jr_cnd_nn(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: UInt8(bitPattern: testCase.addr))

        let cpu = LR35902.zeroed()
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc = testCase.result.pc
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
