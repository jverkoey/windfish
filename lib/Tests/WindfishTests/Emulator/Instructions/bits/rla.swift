import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    let fc: Bool
    struct Result {
      let fc: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(value: 0,           fc: false, result: .init(fc: false, value: 0)),
      "0000_0001":  .init(value: 0b0000_0001, fc: false, result: .init(fc: false, value: 0b0000_0010)),
      "0000_1000":  .init(value: 0b0000_1000, fc: false, result: .init(fc: false, value: 0b0001_0000)),
      "1000_0000":  .init(value: 0b1000_0000, fc: false, result: .init(fc: true,  value: 0)),
      "c0000_0000": .init(value: 0,           fc: true,  result: .init(fc: false, value: 0b0000_0001)),
      "c0000_0001": .init(value: 0b0000_0001, fc: true,  result: .init(fc: false, value: 0b0000_0011)),
      "c1000_0000": .init(value: 0b1000_0000, fc: true,  result: .init(fc: true,  value: 0b0000_0001)),
    ]
  }

  func test_rla() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.rla(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.value
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = true
        cpu.fcarry = testCase.fc
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.fcarry = testCase.result.fc
        mutations.fzero = false
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.a = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
