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
      "zero":            .init(a: 0,    mem: 0,   result: .init(fz: true,  fc: false, fh: false, a: 0)),
      "positive":        .init(a: 0,    mem: 1,   result: .init(fz: false, fc: false, fh: false, a: 1)),
      "overflowzero":    .init(a: 0xff, mem: 1,   result: .init(fz: true,  fc: true,  fh: true,  a: 0)),
      "overflownonzero": .init(a: 0xff, mem: 2,   result: .init(fz: false, fc: true,  fh: true,  a: 1)),
      "halfcarry":       .init(a: 0xf,  mem: 1,   result: .init(fz: false, fc: false, fh: true,  a: 0x10)),
      "halfcarryff":     .init(a: 0xf,  mem: 0xf, result: .init(fz: false, fc: false, fh: true,  a: 0x1e)),
      "nohalfcarry10":   .init(a: 0x10, mem: 0xf, result: .init(fz: false, fc: false, fh: false, a: 0x1f)),
    ]
  }

  func test_add_a_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.add_a_hladdr(spec: spec) else { continue }
        let memory = TestMemory(defaultReadValue: testCase.mem)
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 2, "Test case: \(name)")
        mutations.a = testCase.result.a
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_add_a_n() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.add_a_n(spec: spec) else { continue }
        let memory = TestMemory(defaultReadValue: testCase.mem)
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 2, "Test case: \(name)")
        mutations.pc += 1
        mutations.a = testCase.result.a
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
