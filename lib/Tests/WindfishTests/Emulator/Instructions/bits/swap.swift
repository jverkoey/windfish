import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fz: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":       .init(value: 0,           result: .init(fz: true,  value: 0)),
      "0000_0001":  .init(value: 0b0000_0001, result: .init(fz: false, value: 0b0001_0000)),
      "0001_0000":  .init(value: 0b0001_0000, result: .init(fz: false, value: 0b0000_0001)),
      "1000_0000":  .init(value: 0b1000_0000, result: .init(fz: false, value: 0b0000_1000)),
    ]
  }

  func test_swap_r() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .cb(.swap(let register)) = spec, let emulator = LR35902.Emulation.swap_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.fcarry = true
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_swap_hladdr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.swap_hladdr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.hl = 0x1234
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.fcarry = true
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 3, "Test case: \(name)")
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        assertEqual(cpu, mutations, message: "Test case: \(name)")
        XCTAssertEqual(memory.reads, [0x1234], "\(name)")
        XCTAssertEqual(memory.writes, [
          .init(byte: testCase.result.value, address: 0x1234),
        ], "\(name)")
      }
    }
  }
}
