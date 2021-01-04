import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let addr: Int8
    let fc: Bool
    let fz: Bool
    struct Result {
      let cycles: [LR35902.Instruction.Condition: Int]
      let pc: [LR35902.Instruction.Condition: UInt16]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "+nc_nz": .init(addr: 2,  fc: false, fz: false, result: .init(cycles: [.nz: 3, .z: 2, .nc: 3, .c: 2],
                                                                    pc:     [.nz: 4, .z: 2, .nc: 4, .c: 2])),
      "+c_z":   .init(addr: 2,  fc: true,  fz: true,  result: .init(cycles: [.nz: 2, .z: 3, .nc: 2, .c: 3],
                                                                    pc:     [.nz: 2, .z: 4, .nc: 2, .c: 4])),
      "-nc_nz": .init(addr: -2, fc: false, fz: false, result: .init(cycles: [.nz: 3, .z: 2, .nc: 3, .c: 2],
                                                                    pc:     [.nz: 0, .z: 2, .nc: 0, .c: 2])),
      "-c_z":   .init(addr: -2, fc: true,  fz: true,  result: .init(cycles: [.nz: 2, .z: 3, .nc: 2, .c: 3],
                                                                    pc:     [.nz: 2, .z: 0, .nc: 2, .c: 0])),
    ]
  }

  func test_jr_cnd_nn() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .jr(let _cnd, .simm8) = spec, let cnd = _cnd,
              let emulator = LR35902.Emulation.jr_cnd_nn(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: UInt8(bitPattern: testCase.addr))

        let cpu = LR35902.zeroed()
        cpu.fcarry = testCase.fc
        cpu.fzero = testCase.fz
        cpu.pc = 1
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, testCase.result.cycles[cnd]!, "Test case: \(name) \(cnd)")
        mutations.pc = testCase.result.pc[cnd]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(cnd)")
      }
    }
  }
}
