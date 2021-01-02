import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fz: [LR35902.Instruction.Bit: Bool]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero": .init(value: 0,    result: .init(fz: [.b0: true,  .b1: true,  .b2: true,  .b3: true,  .b4: true,  .b5: true,  .b6: true,  .b7: true])),
      "all":  .init(value: 0xff, result: .init(fz: [.b0: false, .b1: false, .b2: false, .b3: false, .b4: false, .b5: false, .b6: false, .b7: false])),
      "low":  .init(value: 0xf,  result: .init(fz: [.b0: false, .b1: false, .b2: false, .b3: false, .b4: true,  .b5: true,  .b6: true,  .b7: true])),
      "high": .init(value: 0xf0, result: .init(fz: [.b0: true,  .b1: true,  .b2: true,  .b3: true,  .b4: false, .b5: false, .b6: false, .b7: false])),
    ]
  }

  func test_bit_b_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.bit(let bit, let register)) = spec,
              let emulator = LR35902.Emulation.bit_b_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 1, "Test case: \(name) \(bit)")
        mutations.fzero = testCase.result.fz[bit]!
        mutations.fhalfcarry = true
        mutations.fsubtract = false
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }

  func test_bit_b_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.bit(let bit, _)) = spec,
              let emulator = LR35902.Emulation.bit_b_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 4, "Test case: \(name) \(bit)")
        mutations.fzero = testCase.result.fz[bit]!
        mutations.fhalfcarry = true
        mutations.fsubtract = false
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }
}
