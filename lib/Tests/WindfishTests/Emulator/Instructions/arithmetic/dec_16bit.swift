import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt16
    struct Result {
      let value: UInt16
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":        .init(value: 1,      result: .init(value: 0)),
      "positive":    .init(value: 2,      result: .init(value: 1)),
      "hightolow":   .init(value: 0xff00, result: .init(value: 0xfeff)),
      "underflow":   .init(value: 0,      result: .init(value: 0xffff)),
    ]
  }

  func test_dec_rr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .dec(let register) = spec,
              let emulator = LR35902.Emulation.dec_rr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 2, "Test case: \(name)")
        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
