import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let fz: Bool
      let fh: Bool
      let value: UInt8
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero":        .init(value: 1,    result: .init(fz: true,  fh: false, value: 0)),
      "positive":    .init(value: 2,    result: .init(fz: false, fh: false, value: 1)),
      "underflow":   .init(value: 0,    result: .init(fz: false, fh: true,  value: 0xff)),
      "halfcarry":   .init(value: 0x10, result: .init(fz: false, fh: true,  value: 0xf)),
      "nohalfcarry": .init(value: 0x11, result: .init(fz: false, fh: false, value: 0x10)),
    ]
  }

  func test_dec_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .dec(let register) = spec,
              let emulator = LR35902.Emulation.dec_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu.fsubtract = false
        cpu[register] = testCase.value
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 1, "Test case: \(name)")
        mutations.fsubtract = true
        mutations.fzero = testCase.result.fz
        mutations.fhalfcarry = testCase.result.fh
        mutations[register] = testCase.result.value
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }

  func test_dec_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard let emulator = LR35902.Emulation.dec_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.value)
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
        XCTAssertEqual(memory.writes, [
          .init(byte: testCase.result.value, address: 0)
        ])
        assertEqual(cpu, mutations, message: "Test case: \(name)")
      }
    }
  }
}
