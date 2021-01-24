import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let a: UInt8
    let mem: UInt8
    struct Result {
      let fz: Bool
      let fc: Bool
      let fh: Bool
      let a: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":        .init(a: 0,    mem: 0, result: .init(fz: true,  fc: false, fh: false, a: 0)),
      "underflow":   .init(a: 0,    mem: 1, result: .init(fz: false, fc: true,  fh: true,  a: 0xff)),
      "halfcarry":   .init(a: 0xf0, mem: 1, result: .init(fz: false, fc: false, fh: true,  a: 0xef)),
      "nohalfcarry": .init(a: 0xf,  mem: 1, result: .init(fz: false, fc: false, fh: false, a: 0xe)),
    ]
  }

  func test_sub_a_a() {
    let testCases: [String: TestCase] = [
      "zero": .init(a: 0,    mem: 0, result: .init(fz: true, fc: false, fh: false, a: 0)),
      "ff":   .init(a: 0xff, mem: 0, result: .init(fz: true, fc: false, fh: false, a: 0)),
      "f":    .init(a: 0xf,  mem: 0, result: .init(fz: true, fc: false, fh: false, a: 0)),
    ]
    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .sub(.a, .a) = spec,
              let emulator = LR35902.Emulation.sub_a_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.a = testCase.result.a
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_sub_a_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .sub(.a, let register) = spec, register != .a,
              let emulator = LR35902.Emulation.sub_a_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        cpu[register] = testCase.mem
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.a = testCase.result.a
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_sub_a_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.sub_a_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.mem)
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.a = testCase.result.a
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_sub_a_n() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.sub_a_n(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.mem)
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc += 1
        mutations.a = testCase.result.a
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
