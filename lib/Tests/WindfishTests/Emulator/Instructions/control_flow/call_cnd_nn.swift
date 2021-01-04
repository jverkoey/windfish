import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let sp: UInt16
    let fc: Bool
    let fz: Bool
    struct Result {
      let cycles: [LR35902.Instruction.Condition: Int]
      let pc: [LR35902.Instruction.Condition: UInt16]
      let sp: [LR35902.Instruction.Condition: UInt16]
      let spaddr: [LR35902.Instruction.Condition: (h: UInt16, l: UInt16)]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "nc_nz": .init(sp: 2, fc: false, fz: false, result: .init(cycles: [.nz: 6,      .z: 3, .nc: 6,      .c: 3],
                                                                pc:     [.nz: 0x1212, .z: 2, .nc: 0x1212, .c: 2],
                                                                sp:     [.nz: 0,      .z: 2, .nc: 0,      .c: 2],
                                                                spaddr: [.nz: (h: 1, l: 0),  .nc: (h: 1, l: 0)])),
      "c_z": .init(sp: 2, fc: true, fz: true, result: .init(cycles: [.nz: 3, .z: 6,      .nc: 3, .c: 6],
                                                            pc:     [.nz: 2, .z: 0x1212, .nc: 2, .c: 0x1212],
                                                            sp:     [.nz: 2, .z: 0,      .nc: 2, .c: 0],
                                                            spaddr: [        .z: (h: 1, l: 0),   .c: (h: 1, l: 0)])),
    ]
  }

  func test_call_cnd_nn() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .call(let _cnd, .imm16) = spec, let cnd = _cnd,
              let emulator = LR35902.Emulation.call_cnd_nn(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        cpu.fcarry = testCase.fc
        cpu.fzero = testCase.fz
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, testCase.result.cycles[cnd]!, "Test case: \(name) \(cnd)")
        mutations.pc = testCase.result.pc[cnd]!
        mutations.sp = testCase.result.sp[cnd]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(cnd)")
        XCTAssertEqual(memory.reads, [0, 1], "Test case: \(name) \(cnd)")
        if let spaddr = testCase.result.spaddr[cnd] {
          XCTAssertEqual(memory.writes, [
            .init(byte: 0x00, address: spaddr.h),
            .init(byte: 0x02, address: spaddr.l),
          ], "Test case: \(name) \(cnd)")
        }
      }
    }
  }
}
