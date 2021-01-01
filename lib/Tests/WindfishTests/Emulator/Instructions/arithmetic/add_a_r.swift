import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let a: UInt8
    let reg: UInt8
    struct Result {
      let fz: Bool
      let fc: Bool
      let fh: Bool
      let a: UInt8
    }
    let result: Result
  }

  // Test the a, a case separately because it's a doubling rather than an addition.
  func test_add_a_a() {
    let testCases: [String: TestCase] = [
      "zero":            .init(a: 0,    reg: 0, result: .init(fz: true,  fc: false, fh: false, a: 0)),
      "positive":        .init(a: 1,    reg: 0, result: .init(fz: false, fc: false, fh: false, a: 2)),
      "overflowzero":    .init(a: 0x80, reg: 0, result: .init(fz: true,  fc: true,  fh: false, a: 0)),
      "overflownonzero": .init(a: 0x81, reg: 0, result: .init(fz: false, fc: true,  fh: false, a: 2)),
      "halfcarry":       .init(a: 0xf,  reg: 0, result: .init(fz: false, fc: false, fh: true,  a: 0x1e)),
      "nohalfcarry10":   .init(a: 0x10, reg: 0, result: .init(fz: false, fc: false, fh: false, a: 0x20)),
    ]
    for (name, testCase) in testCases {
      let memory = TestMemory()
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .add(.a, .a) = spec else {
          continue
        }
        guard let emulator = LR35902.Emulation.add_a_r(spec: spec) else { continue }
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.a = testCase.result.a
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_add_a_r() {
    let testCases: [String: TestCase] = [
      "zero":            .init(a: 0,    reg: 0,   result: .init(fz: true,  fc: false, fh: false, a: 0)),
      "positive":        .init(a: 0,    reg: 1,   result: .init(fz: false, fc: false, fh: false, a: 1)),
      "overflowzero":    .init(a: 0xff, reg: 1,   result: .init(fz: true,  fc: true,  fh: true,  a: 0)),
      "overflownonzero": .init(a: 0xff, reg: 2,   result: .init(fz: false, fc: true,  fh: true,  a: 1)),
      "halfcarry":       .init(a: 0xf,  reg: 1,   result: .init(fz: false, fc: false, fh: true,  a: 0x10)),
      "halfcarryff":     .init(a: 0xf,  reg: 0xf, result: .init(fz: false, fc: false, fh: true,  a: 0x1e)),
      "nohalfcarry10":   .init(a: 0x10, reg: 0xf, result: .init(fz: false, fc: false, fh: false, a: 0x1f)),
    ]
    for (name, testCase) in testCases {
      let memory = TestMemory()
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .add(.a, let register) = spec, register != .a else {
          continue
        }
        guard let emulator = LR35902.Emulation.add_a_r(spec: spec) else { continue }
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        cpu[register] = testCase.reg
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.a = testCase.result.a
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
