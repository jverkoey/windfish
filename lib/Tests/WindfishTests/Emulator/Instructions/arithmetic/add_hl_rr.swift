import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let hl: UInt16
    let reg: UInt16
    struct Result {
      let fc: Bool
      let fh: Bool
      let hl: UInt16
    }
    let result: Result
  }

  // Test the hl, hl case separately because it's a doubling rather than an addition.
  func test_add_hl_hl() {
    let testCases: [String: TestCase] = [
      "zero":            .init(hl: 0,      reg: 0, result: .init(fc: false, fh: false, hl: 0)),
      "positive":        .init(hl: 1,      reg: 0, result: .init(fc: false, fh: false, hl: 2)),
      "overflowzero":    .init(hl: 0x8000, reg: 0, result: .init(fc: true,  fh: false, hl: 0)),
      "overflownonzero": .init(hl: 0x8001, reg: 0, result: .init(fc: true,  fh: false, hl: 2)),
      "halfcarry":       .init(hl: 0xf00,  reg: 0, result: .init(fc: false, fh: true,  hl: 0x1e00)),
      "nohalfcarry10":   .init(hl: 0x1000, reg: 0, result: .init(fc: false, fh: false, hl: 0x2000)),
    ]
    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .add(.hl, .hl) = spec,
              let emulator = LR35902.Emulation.add_hl_rr(spec: spec) else { continue }
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.hl = testCase.hl
        cpu.fzero = true
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 2, "Test case: \(name)")
        mutations.hl = testCase.result.hl
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_add_hl_rr() {
    let testCases: [String: TestCase] = [
      "zero":            .init(hl: 0,      reg: 0,     result: .init(fc: false, fh: false, hl: 0)),
      "positive":        .init(hl: 0,      reg: 1,     result: .init(fc: false, fh: false, hl: 1)),
      "overflowzero":    .init(hl: 0xffff, reg: 1,     result: .init(fc: true,  fh: true,  hl: 0)),
      "overflownonzero": .init(hl: 0xffff, reg: 2,     result: .init(fc: true,  fh: true,  hl: 1)),
      "halfcarry":       .init(hl: 0xfff,  reg: 1,     result: .init(fc: false, fh: true,  hl: 0x1000)),
      "halfcarryff":     .init(hl: 0xfff,  reg: 0xfff, result: .init(fc: false, fh: true,  hl: 0x1ffe)),
      "nohalfcarry10":   .init(hl: 0x1000, reg: 0xfff, result: .init(fc: false, fh: false, hl: 0x1fff)),
    ]
    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .add(.hl, let register) = spec, register != .hl,
              let emulator = LR35902.Emulation.add_hl_rr(spec: spec) else { continue }
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.hl = testCase.hl
        cpu.fzero = true
        cpu[register] = testCase.reg
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 2, "Test case: \(name)")
        mutations.hl = testCase.result.hl
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
