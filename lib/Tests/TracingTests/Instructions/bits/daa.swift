import XCTest

import LR35902
@testable import Tracing

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    let fn: Bool
    let fc: Bool
    let fh: Bool
    struct Result {
      let fz: Bool
      let fc: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      // Addition
      "+zero":   .init(value: 0,           fn: false, fc: false, fh: false, result: .init(fz: true,  fc: false, value: 0)),
      "+zeroc":  .init(value: 0,           fn: false, fc: true,  fh: false, result: .init(fz: false, fc: true,  value: 0b0110_0000)),
      "+zeroh":  .init(value: 0,           fn: false, fc: false, fh: true,  result: .init(fz: false, fc: false, value: 0b0000_0110)),
      "+zeroch": .init(value: 0,           fn: false, fc: true,  fh: true,  result: .init(fz: false, fc: true,  value: 0b0110_0110)),
      "+one":    .init(value: 0b0001_0001, fn: false, fc: false, fh: false, result: .init(fz: false, fc: false, value: 0b0001_0001)),
      "+onec":   .init(value: 0b0001_0001, fn: false, fc: true,  fh: false, result: .init(fz: false, fc: true,  value: 0b0111_0001)),
      "+oneh":   .init(value: 0b0001_0001, fn: false, fc: false, fh: true,  result: .init(fz: false, fc: false, value: 0b0001_0111)),
      "+onech":  .init(value: 0b0001_0001, fn: false, fc: true,  fh: true,  result: .init(fz: false, fc: true,  value: 0b0111_0111)),

      // Subtraction
      "-zero":   .init(value: 0,           fn: true, fc: false, fh: false, result: .init(fz: true,  fc: false, value: 0)),
      "-zeroc":  .init(value: 0,           fn: true, fc: true,  fh: false, result: .init(fz: false, fc: true,  value: 0b1010_0000)),
      "-zeroh":  .init(value: 0,           fn: true, fc: false, fh: true,  result: .init(fz: false, fc: false, value: 0b1111_1010)),
      "-zeroch": .init(value: 0,           fn: true, fc: true,  fh: true,  result: .init(fz: false, fc: true,  value: 0b1001_1010)),
      "-one":    .init(value: 0b0001_0001, fn: true, fc: false, fh: false, result: .init(fz: false, fc: false, value: 0b0001_0001)),
      "-onec":   .init(value: 0b0001_0001, fn: true, fc: true,  fh: false, result: .init(fz: false, fc: true,  value: 0b1011_0001)),
      "-oneh":   .init(value: 0b0001_0001, fn: true, fc: false, fh: true,  result: .init(fz: false, fc: false, value: 0b0000_1011)),
      "-onech":  .init(value: 0b0001_0001, fn: true, fc: true,  fh: true,  result: .init(fz: false, fc: true,  value: 0b1010_1011)),
    ]
  }

  func test_daa() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.daa(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.value
        cpu.fsubtract = testCase.fn
        cpu.fcarry = testCase.fc
        cpu.fhalfcarry = testCase.fh
        cpu.fzero = !testCase.result.fz
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.a = testCase.result.value
        mutations.fhalfcarry = false
        mutations.fzero = testCase.result.fz
        mutations.fcarry = testCase.result.fc
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
