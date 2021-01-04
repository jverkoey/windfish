import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let sp: UInt16
    let imm8: Int8
    struct Result {
      let fc: Bool
      let fh: Bool
      let sp: UInt16
    }
    let result: Result
  }
  func test_add_sp_n() {
    let testCases: [String: TestCase] = [
      "zero":       .init(sp: 0,      imm8: 0,    result: .init(fc: false, fh: false, sp: 0)),
      "positive":   .init(sp: 0,      imm8: 1,    result: .init(fc: false, fh: false, sp: 1)),
      // The c and h flags look inverted here, but remember that subtractions are just really large additions.
      "carry":      .init(sp: 2,      imm8: -1,   result: .init(fc: true,  fh: true,  sp: 1)),
      "nocarry":    .init(sp: 0,      imm8: -1,   result: .init(fc: false, fh: false, sp: 0xffff)),
      "overflow":   .init(sp: 0xffff, imm8: 1,    result: .init(fc: true,  fh: true,  sp: 0)),
      "halfcarry":  .init(sp: 0xf,    imm8: 1,    result: .init(fc: false, fh: true,  sp: 0x10)),
      "halfcarry2": .init(sp: 0xf,    imm8: 0x11, result: .init(fc: false, fh: true,  sp: 0x20)),
    ]

    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.add_sp_n(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: UInt8(bitPattern: testCase.imm8))
        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 4, "Test case: \(name)")
        mutations.pc += 1
        mutations.sp = testCase.result.sp
        mutations.fcarry = testCase.result.fc
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
