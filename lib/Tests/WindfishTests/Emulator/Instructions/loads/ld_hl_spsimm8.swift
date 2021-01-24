import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let sp: UInt16
    let simm8: Int8
    struct Result {
      let fc: Bool
      let fh: Bool
      let hl: UInt16
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":      .init(sp: 0xfffe, simm8: 0,  result: .init(fc: false, fh: false, hl: 0xfffe)),
      "+1":        .init(sp: 0xfffe, simm8: 1,  result: .init(fc: false, fh: false, hl: 0xffff)),
      "-1":        .init(sp: 0xfffe, simm8: -1, result: .init(fc: true,  fh: true,  hl: 0xfffd)),
      "overflow":  .init(sp: 0xfffe, simm8: 2,  result: .init(fc: true,  fh: true,  hl: 0)),
      "halfcarry": .init(sp: 0x000f, simm8: 1,  result: .init(fc: false, fh: true,  hl: 0x0010)),
    ]
  }

  func test_ld_hl_spsimm8() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_hl_spsimm8(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: UInt8(bitPattern: testCase.simm8))

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        let mutations = cpu.copy()
        mutations.hl = testCase.result.hl
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        mutations.pc += 1

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        assertEqual(cpu, mutations, message: name)
      }
    }
  }
}
