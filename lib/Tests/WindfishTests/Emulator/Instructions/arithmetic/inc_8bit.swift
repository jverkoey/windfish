import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fz: Bool
      let fh: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "overflow":    .init(value: 0xff, result: .init(fz: true,  fh: true,  value: 0)),
      "positive":    .init(value: 0,    result: .init(fz: false, fh: false, value: 1)),
      "halfcarry":   .init(value: 0xf,  result: .init(fz: false, fh: true,  value: 0x10)),
      "nohalfcarry": .init(value: 0x11, result: .init(fz: false, fh: false, value: 0x12)),
    ]
  }

  func test_inc_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .inc(let register) = spec,
              let emulator = LR35902.Emulation.inc_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fsubtract = false
        mutations.fzero = testCase.result.fz
        mutations.fhalfcarry = testCase.result.fh
        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_inc_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.inc_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fsubtract = false
        mutations.fzero = testCase.result.fz
        mutations.fhalfcarry = testCase.result.fh
        XCTAssertEqual(memory.writes, [
          .init(byte: testCase.result.value, address: 0)
        ])
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
