import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let fc: Bool
    let fz: Bool
    struct Result {
      let cycles: [LR35902.Instruction.Condition: Int]
      let pc: [LR35902.Instruction.Condition: UInt16]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "nc_nz": .init(fc: false, fz: false, result: .init(cycles: [.nz: 4,      .z: 3, .nc: 4,      .c: 3],
                                                         pc:     [.nz: 0x1212, .z: 2, .nc: 0x1212, .c: 2])),
      "c_z": .init(fc: true, fz: true, result: .init(cycles: [.nz: 3, .z: 4,      .nc: 3, .c: 4],
                                                     pc:     [.nz: 2, .z: 0x1212, .nc: 2, .c: 0x1212])),
    ]
  }

  func test_jp_cnd_nn() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .jp(let _cnd, .imm16) = spec, let cnd = _cnd,
              let emulator = LR35902.Emulation.jp_cnd_nn(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.fcarry = testCase.fc
        cpu.fzero = testCase.fz
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, testCase.result.cycles[cnd]!, "Test case: \(name) \(cnd)")
        mutations.pc = testCase.result.pc[cnd]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(cnd)")
      }
    }
  }
}
