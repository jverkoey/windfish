import XCTest

import LR35902
@testable import Tracing

extension InstructionEmulatorTests {
  private struct TestCase {
    let a: UInt8
    let value: UInt8
    struct Result {
      let fz: Bool
      let fc: Bool
      let fh: Bool
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(a: 0,    value: 0, result: .init(fz: true,  fc: false, fh: false)),
      "<":          .init(a: 1,    value: 2, result: .init(fz: false, fc: true,  fh: true)),
      ">":          .init(a: 2,    value: 1, result: .init(fz: false, fc: false, fh: false)),
      ">halfcarry": .init(a: 0x10, value: 1, result: .init(fz: false, fc: false, fh: true)),
    ]
  }

  // cp a, a requires a separate test case because the result is always the same
  func test_cp_a() {
    let testCases: [String: TestCase] = [
      "zero": .init(a: 0,    value: 0, result: .init(fz: true, fc: false, fh: false)),
      "low":  .init(a: 0xf,  value: 0, result: .init(fz: true, fc: false, fh: false)),
      "high": .init(a: 0xf0, value: 0, result: .init(fz: true, fc: false, fh: false)),
      "max":  .init(a: 0xff, value: 0, result: .init(fz: true, fc: false, fh: false)),
    ]
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .cp(.a) = spec, let emulator = LR35902.Emulation.cp_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        cpu.fhalfcarry = !testCase.result.fh
        cpu.fcarry = !testCase.result.fc
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fsubtract = true
        mutations.fhalfcarry = testCase.result.fh
        mutations.fcarry = testCase.result.fc
        mutations.fzero = testCase.result.fz
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_cp_hladdr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.cp_hladdr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fsubtract = true
        mutations.fhalfcarry = testCase.result.fh
        mutations.fcarry = testCase.result.fc
        mutations.fzero = testCase.result.fz
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_cp_n() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.cp_n(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc += 1
        mutations.fsubtract = true
        mutations.fhalfcarry = testCase.result.fh
        mutations.fcarry = testCase.result.fc
        mutations.fzero = testCase.result.fz
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_cp_r() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .cp(let register) = spec, register != .a, let emulator = LR35902.Emulation.cp_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.fsubtract = true
        mutations.fhalfcarry = testCase.result.fh
        mutations.fcarry = testCase.result.fc
        mutations.fzero = testCase.result.fz
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }
}
