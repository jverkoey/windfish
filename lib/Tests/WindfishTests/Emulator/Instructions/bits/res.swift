import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let value: [LR35902.Instruction.Bit: UInt8]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero": .init(value: 0,    result: .init(value: [.b0: 0,    .b1: 0,    .b2: 0,    .b3: 0,    .b4: 0,    .b5: 0,    .b6: 0,    .b7: 0])),
      "all":  .init(value: 0xff, result: .init(value: [.b0: 0xfe, .b1: 0xfd, .b2: 0xfb, .b3: 0xf7, .b4: 0xef, .b5: 0xdf, .b6: 0xbf, .b7: 0x7f])),
    ]
  }

  func test_res_b_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.res(let bit, let register)) = spec,
              let emulator = LR35902.Emulation.res_b_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations[register] = testCase.result.value[bit]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }

  func test_res_b_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.res(let bit, .hladdr)) = spec,
              let emulator = LR35902.Emulation.res_b_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        XCTAssertEqual(memory.writes, [
          .init(byte: testCase.result.value[bit]!, address: 0)
        ])
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }
}
