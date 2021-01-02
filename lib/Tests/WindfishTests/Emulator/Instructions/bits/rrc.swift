import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fz: Bool
      let fc: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(value: 0,           result: .init(fz: true,  fc: false, value: 0)),
      "0000_0001":  .init(value: 0b0000_0001, result: .init(fz: false, fc: true,  value: 0b1000_0000)),
      "0001_0000":  .init(value: 0b0001_0000, result: .init(fz: false, fc: false, value: 0b0000_1000)),
      "1000_0000":  .init(value: 0b1000_0000, result: .init(fz: false, fc: false, value: 0b0100_0000)),
    ]
  }

  func test_rrc_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.rrc(let register)) = spec,
              let emulator = LR35902.Emulation.rrc_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.fcarry = !testCase.result.fc
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.fcarry = testCase.result.fc
        mutations.fzero = testCase.result.fz
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
