import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let a: UInt8
    let imm8: UInt8
    let fc: Bool
    struct Result {
      let fz: Bool
      let fc: Bool
      let fh: Bool
      let a: UInt8
    }
    let result: Result
  }
  func test_adc_n() {
    let testCases: [String: TestCase] = [
      "zero":            .init(a: 0,    imm8: 0,    fc: false, result: .init(fz: true,  fc: false, fh: false, a: 0)),
      "positive":        .init(a: 0,    imm8: 1,    fc: false, result: .init(fz: false, fc: false, fh: false, a: 1)),
      "overflowzero":    .init(a: 0xff, imm8: 1,    fc: false, result: .init(fz: true,  fc: true,  fh: true,  a: 0)),
      "overflownonzero": .init(a: 0xff, imm8: 2,    fc: false, result: .init(fz: false, fc: true,  fh: true,  a: 1)),
      "halfcarry":       .init(a: 0x0f, imm8: 1,    fc: false, result: .init(fz: false, fc: false, fh: true,  a: 0x10)),
      "halfcarry2":      .init(a: 0x0f, imm8: 0x11, fc: false, result: .init(fz: false, fc: false, fh: true,  a: 0x20)),

      "czero":            .init(a: 0,    imm8: 0,    fc: true, result: .init(fz: false, fc: false, fh: false, a: 1)),
      "cpositive":        .init(a: 0,    imm8: 1,    fc: true, result: .init(fz: false, fc: false, fh: false, a: 2)),
      "coverflowzero":    .init(a: 0xfe, imm8: 1,    fc: true, result: .init(fz: true,  fc: true,  fh: true,  a: 0)),
      "coverflownonzero": .init(a: 0xff, imm8: 2,    fc: true, result: .init(fz: false, fc: true,  fh: true,  a: 2)),
      "chalfcarry":       .init(a: 0x0f, imm8: 1,    fc: true, result: .init(fz: false, fc: false, fh: true,  a: 0x11)),
      "chalfcarry2":      .init(a: 0x0f, imm8: 0x11, fc: true, result: .init(fz: false, fc: false, fh: true,  a: 0x21)),
    ]

    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.adc_n(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.imm8)
        let cpu = LR35902.zeroed()
        cpu.a = testCase.a
        cpu.fcarry = testCase.fc
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
