import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let a: UInt8
    let value: UInt8
    struct Result {
      let fz: Bool
      let a: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":        .init(a: 0,           value: 0,           result: .init(fz: true,  a: 0)),
      "==":          .init(a: 1,           value: 1,           result: .init(fz: false, a: 1)),
      "no_overlap":  .init(a: 0b0000_1111, value: 0b1111_0000, result: .init(fz: false, a: 0b1111_1111)),
      "someoverlap": .init(a: 0b0001_1110, value: 0b0111_1000, result: .init(fz: false, a: 0b0111_1110)),
    ]
  }

  // or a, a requires a separate test case because the result is always the same
  func test_or_a() {
    let testCases: [String: TestCase] = [
      "zero":        .init(a: 0,           value: 0, result: .init(fz: true,  a: 0)),
      "==":          .init(a: 1,           value: 0, result: .init(fz: false, a: 1)),
      "no_overlap":  .init(a: 0b0000_1111, value: 0, result: .init(fz: false, a: 0b0000_1111)),
      "someoverlap": .init(a: 0b0001_1111, value: 0, result: .init(fz: false, a: 0b0001_1111)),
    ]
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .or(.a) = spec, let emulator = LR35902.Emulation.or_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 1, "Test case: \(name) \(spec)")
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.a = testCase.result.a
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_or_hladdr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.or_hladdr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 2, "Test case: \(name) \(spec)")
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.a = testCase.result.a
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_or_n() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.or_n(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 2, "Test case: \(name) \(spec)")
        mutations.pc += 1
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.a = testCase.result.a
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }

  func test_or_r() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .or(let register) = spec, register != .a, let emulator = LR35902.Emulation.or_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      for (name, testCase) in TestCase.testCases {
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = true
        cpu.fhalfcarry = true
        cpu.fcarry = true
        cpu.fzero = !testCase.result.fz
        cpu.a = testCase.a
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
        XCTAssertEqual(cycle, 1, "Test case: \(name) \(spec)")
        mutations.fsubtract = false
        mutations.fhalfcarry = false
        mutations.fcarry = false
        mutations.fzero = testCase.result.fz
        mutations.a = testCase.result.a
        assertEqual(cpu, mutations, message: "Test case: \(name) \(spec)")
      }
    }
  }
}
