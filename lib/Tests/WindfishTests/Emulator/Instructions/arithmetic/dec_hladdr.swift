import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let mem: Int8
    struct Result {
      let fz: Bool
      let fh: Bool
    }
    let result: Result
  }
  func test_dec_hladdr() {
    let testCases: [String: TestCase] = [
      "zero":        .init(mem: 1,    result: .init(fz: true,  fh: false)),
      "positive":    .init(mem: 2,    result: .init(fz: false, fh: false)),
      "underflow":   .init(mem: 0,    result: .init(fz: false, fh: true)),
      "halfcarry":   .init(mem: 0x10, result: .init(fz: false, fh: true)),
      "nohalfcarry": .init(mem: 0x11, result: .init(fz: false, fh: false)),
    ]

    for (name, testCase) in testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.dec_hladdr(spec: spec) else { continue }
        let memory = TestMemory(defaultReadValue: UInt8(bitPattern: testCase.mem))
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 3, "Test case: \(name)")
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fhalfcarry = testCase.result.fh
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
