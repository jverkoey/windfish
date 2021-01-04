import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero": .init(value: 0,    result: .init(value: 0xff)),
      "all":  .init(value: 0xff, result: .init(value: 0)),
      "low":  .init(value: 0xf,  result: .init(value: 0xf0)),
      "high": .init(value: 0xf0, result: .init(value: 0xf)),
    ]
  }

  func test_cpl() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.cpl(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.a = testCase.value
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.a = testCase.result.value
        mutations.fhalfcarry = true
        mutations.fsubtract = true
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
