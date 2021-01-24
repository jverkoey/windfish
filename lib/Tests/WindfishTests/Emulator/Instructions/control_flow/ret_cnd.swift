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
      "nc_nz": .init(sp: 2, fc: false, fz: false, result: .init(cycles: [.nz: 5,      .z: 2, .nc: 5,      .c: 2],
                                                                pc:     [.nz: 0x1212, .z: 1, .nc: 0x1212, .c: 1],
                                                                sp:     [.nz: 4,      .z: 2, .nc: 4,      .c: 2],
                                                                spaddr: [.nz: (h: 3, l: 2),  .nc: (h: 3, l: 2)])),
      "c_z":   .init(sp: 2, fc: true,  fz: true,  result: .init(cycles: [.nz: 2, .z: 5,      .nc: 2, .c: 5],
                                                                pc:     [.nz: 1, .z: 0x1212, .nc: 1, .c: 0x1212],
                                                                sp:     [.nz: 2, .z: 4,      .nc: 2, .c: 4],
                                                                spaddr: [        .z: (h: 3, l: 2),   .c: (h: 3, l: 2)])),
    ]
  }

  func test_ret_cnd() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .ret(let _cnd) = spec, let cnd = _cnd,
              let emulator = LR35902.Emulation.ret_cnd(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        cpu.fcarry = testCase.fc
        cpu.fzero = testCase.fz
        cpu.pc = 1
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc = testCase.result.pc[cnd]!
        mutations.sp = testCase.result.sp[cnd]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(cnd)")
        if let spaddr = testCase.result.spaddr[cnd] {
          XCTAssertEqual(memory.reads, [spaddr.l, spaddr.h], "Test case: \(name)")
        }
        XCTAssertEqual(memory.writes, [], "Test case: \(name) \(cnd)")
      }
    }
  }
}
